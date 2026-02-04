//
//  DownloadManager.swift
//  SwiftUI-music
//
//  下载管理器 - 管理歌曲离线下载和存储
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 下载管理器
/// 下载管理器 - 单例模式
@MainActor
final class DownloadManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = DownloadManager()
    
    // MARK: - Published 属性
    @Published private(set) var downloadQueue: [DownloadTask] = []
    @Published private(set) var completedDownloads: [DownloadTask] = []
    @Published private(set) var currentDownload: DownloadTask?
    @Published private(set) var isDownloading: Bool = false
    @Published private(set) var totalProgress: Double = 0
    
    // MARK: - 私有属性
    private var downloadSession: URLSession?
    private var currentTask: URLSessionDownloadTask?
    private let fileManager = FileManager.default
    private let maxConcurrentDownloads = 3
    
    private lazy var downloadDirectory: URL = {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let downloadPath = paths[0].appendingPathComponent("Downloads", isDirectory: true)
        if !fileManager.fileExists(atPath: downloadPath.path) {
            try? fileManager.createDirectory(at: downloadPath, withIntermediateDirectories: true)
        }
        return downloadPath
    }()
    
    // MARK: - 初始化
    private init() {
        setupDownloadSession()
        loadCompletedDownloads()
    }
    
    // MARK: - 配置
    
    private func setupDownloadSession() {
        let config = URLSessionConfiguration.background(withIdentifier: "com.music.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        downloadSession = URLSession(configuration: config)
    }
    
    private func loadCompletedDownloads() {
        let downloadedSongs = StorageManager.shared.downloadedSongs
        completedDownloads = downloadedSongs.map { song in
            var task = DownloadTask(song: song)
            task.state = .completed
            task.progress = 1.0
            task.localUrl = getLocalFileUrl(for: song)
            return task
        }
    }
    
    // MARK: - 下载控制
    
    func download(song: Song) {
        guard !isDownloaded(song) else {
            print("⚠️ 歌曲已下载: \(song.title)")
            return
        }
        
        guard !downloadQueue.contains(where: { $0.song.id == song.id }) else {
            print("⚠️ 歌曲已在下载队列: \(song.title)")
            return
        }
        
        if StorageManager.shared.wifiOnlyDownload && !isOnWiFi() {
            print("⚠️ 当前非 WiFi 网络，已设置仅 WiFi 下载")
            return
        }
        
        var task = DownloadTask(song: song)
        task.state = .waiting
        downloadQueue.append(task)
        processQueue()
    }
    
    func downloadBatch(songs: [Song]) {
        for song in songs {
            download(song: song)
        }
    }
    
    func pauseDownload(taskId: UUID) {
        guard let index = downloadQueue.firstIndex(where: { $0.id == taskId }) else { return }
        
        if downloadQueue[index].id == currentDownload?.id {
            currentTask?.cancel()
            currentTask = nil
            currentDownload = nil
            isDownloading = false
        }
        
        downloadQueue[index].state = .paused
    }
    
    func resumeDownload(taskId: UUID) {
        guard let index = downloadQueue.firstIndex(where: { $0.id == taskId }) else { return }
        downloadQueue[index].state = .waiting
        processQueue()
    }
    
    func cancelDownload(taskId: UUID) {
        if currentDownload?.id == taskId {
            currentTask?.cancel()
            currentTask = nil
            currentDownload = nil
            isDownloading = false
        }
        
        downloadQueue.removeAll { $0.id == taskId }
        processQueue()
    }
    
    func cancelAllDownloads() {
        currentTask?.cancel()
        currentTask = nil
        currentDownload = nil
        isDownloading = false
        downloadQueue.removeAll()
    }
    
    func deleteDownload(song: Song) {
        let fileUrl = getLocalFileUrl(for: song)
        try? fileManager.removeItem(at: fileUrl)
        completedDownloads.removeAll { $0.song.id == song.id }
        StorageManager.shared.removeDownloadedSong(song)
    }
    
    // MARK: - 下载处理
    
    private func processQueue() {
        guard currentDownload == nil else { return }
        guard let nextTaskIndex = downloadQueue.firstIndex(where: { $0.state == .waiting }) else { return }
        
        downloadQueue[nextTaskIndex].state = .downloading(progress: 0)
        currentDownload = downloadQueue[nextTaskIndex]
        isDownloading = true
        simulateDownload(taskIndex: nextTaskIndex)
    }
    
    private func simulateDownload(taskIndex: Int) {
        Task {
            var progress: Double = 0
            
            while progress < 1.0 {
                guard taskIndex < downloadQueue.count,
                      case .downloading = downloadQueue[taskIndex].state else { return }
                
                try? await Task.sleep(nanoseconds: 100_000_000)
                progress += 0.05
                
                downloadQueue[taskIndex].progress = min(progress, 1.0)
                downloadQueue[taskIndex].state = .downloading(progress: progress)
                currentDownload = downloadQueue[taskIndex]
                updateTotalProgress()
            }
            
            completeDownload(taskIndex: taskIndex)
        }
    }
    
    private func completeDownload(taskIndex: Int) {
        guard taskIndex < downloadQueue.count else { return }
        
        var task = downloadQueue[taskIndex]
        task.state = .completed
        task.progress = 1.0
        task.localUrl = getLocalFileUrl(for: task.song)
        
        completedDownloads.append(task)
        downloadQueue.remove(at: taskIndex)
        StorageManager.shared.addDownloadedSong(task.song)
        
        currentDownload = nil
        isDownloading = false
        processQueue()
    }
    
    private func updateTotalProgress() {
        let activeDownloads = downloadQueue.filter {
            if case .downloading = $0.state { return true }
            return false
        }
        
        guard !activeDownloads.isEmpty else {
            totalProgress = 0
            return
        }
        
        totalProgress = activeDownloads.reduce(0) { $0 + $1.progress } / Double(activeDownloads.count)
    }
    
    // MARK: - 辅助方法
    
    func isDownloaded(_ song: Song) -> Bool {
        StorageManager.shared.isSongDownloaded(song)
    }
    
    func getDownloadState(for song: Song) -> DownloadState {
        if isDownloaded(song) { return .completed }
        if let task = downloadQueue.first(where: { $0.song.id == song.id }) { return task.state }
        return .idle
    }
    
    func getLocalFileUrl(for song: Song) -> URL {
        downloadDirectory.appendingPathComponent("\(song.id.uuidString).mp3")
    }
    
    private func isOnWiFi() -> Bool { true }
    
    func getDownloadedFileSize() -> Int64 {
        var totalSize: Int64 = 0
        
        if let files = try? fileManager.contentsOfDirectory(at: downloadDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            for file in files {
                if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                   let size = attributes[.size] as? Int64 {
                    totalSize += size
                }
            }
        }
        
        return totalSize
    }
    
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
