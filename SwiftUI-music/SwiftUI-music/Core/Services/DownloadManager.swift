//
//  DownloadManager.swift
//  SwiftUI-music
//
//  下载管理器 - 管理歌曲离线下载和存储
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 下载状态
/// 下载状态枚举
enum DownloadState: Sendable, Equatable {
    case idle           // 空闲
    case waiting        // 等待中
    case downloading(progress: Double)  // 下载中
    case paused         // 已暂停
    case completed      // 已完成
    case failed(String) // 失败
    
    static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.waiting, .waiting),
             (.paused, .paused),
             (.completed, .completed):
            return true
        case (.downloading(let p1), .downloading(let p2)):
            return p1 == p2
        case (.failed(let e1), .failed(let e2)):
            return e1 == e2
        default:
            return false
        }
    }
}

// MARK: - 下载任务
/// 下载任务模型
struct DownloadTask: Identifiable, Sendable {
    let id: UUID
    let song: Song
    var state: DownloadState
    var progress: Double
    var localUrl: URL?
    var createdAt: Date
    
    init(song: Song) {
        self.id = UUID()
        self.song = song
        self.state = .idle
        self.progress = 0
        self.localUrl = nil
        self.createdAt = Date()
    }
}

// MARK: - 下载管理器
/// 下载管理器 - 单例模式
@MainActor
final class DownloadManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = DownloadManager()
    
    // MARK: - Published 属性
    /// 下载队列
    @Published private(set) var downloadQueue: [DownloadTask] = []
    
    /// 已完成的下载
    @Published private(set) var completedDownloads: [DownloadTask] = []
    
    /// 当前下载任务
    @Published private(set) var currentDownload: DownloadTask?
    
    /// 是否正在下载
    @Published private(set) var isDownloading: Bool = false
    
    /// 总下载进度
    @Published private(set) var totalProgress: Double = 0
    
    // MARK: - 私有属性
    private var downloadSession: URLSession?
    private var currentTask: URLSessionDownloadTask?
    private let fileManager = FileManager.default
    
    /// 下载目录
    private lazy var downloadDirectory: URL = {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let downloadPath = paths[0].appendingPathComponent("Downloads", isDirectory: true)
        
        // 确保目录存在
        if !fileManager.fileExists(atPath: downloadPath.path) {
            try? fileManager.createDirectory(at: downloadPath, withIntermediateDirectories: true)
        }
        
        return downloadPath
    }()
    
    /// 最大并发下载数
    private let maxConcurrentDownloads = 3
    
    // MARK: - 初始化
    private init() {
        setupDownloadSession()
        loadCompletedDownloads()
    }
    
    // MARK: - 配置
    
    /// 配置下载会话
    private func setupDownloadSession() {
        let config = URLSessionConfiguration.background(withIdentifier: "com.music.download")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        downloadSession = URLSession(configuration: config)
    }
    
    /// 加载已完成的下载
    private func loadCompletedDownloads() {
        // 从存储中加载
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
    
    /// 开始下载歌曲
    /// - Parameter song: 要下载的歌曲
    func download(song: Song) {
        // 检查是否已下载
        guard !isDownloaded(song) else {
            print("⚠️ 歌曲已下载: \(song.title)")
            return
        }
        
        // 检查是否在下载队列中
        guard !downloadQueue.contains(where: { $0.song.id == song.id }) else {
            print("⚠️ 歌曲已在下载队列: \(song.title)")
            return
        }
        
        // 检查 WiFi 设置
        if StorageManager.shared.wifiOnlyDownload && !isOnWiFi() {
            print("⚠️ 当前非 WiFi 网络，已设置仅 WiFi 下载")
            return
        }
        
        // 创建下载任务
        var task = DownloadTask(song: song)
        task.state = .waiting
        downloadQueue.append(task)
        
        // 开始处理队列
        processQueue()
    }
    
    /// 批量下载歌曲
    /// - Parameter songs: 要下载的歌曲列表
    func downloadBatch(songs: [Song]) {
        for song in songs {
            download(song: song)
        }
    }
    
    /// 暂停下载
    /// - Parameter taskId: 任务 ID
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
    
    /// 恢复下载
    /// - Parameter taskId: 任务 ID
    func resumeDownload(taskId: UUID) {
        guard let index = downloadQueue.firstIndex(where: { $0.id == taskId }) else { return }
        downloadQueue[index].state = .waiting
        processQueue()
    }
    
    /// 取消下载
    /// - Parameter taskId: 任务 ID
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
    
    /// 取消所有下载
    func cancelAllDownloads() {
        currentTask?.cancel()
        currentTask = nil
        currentDownload = nil
        isDownloading = false
        downloadQueue.removeAll()
    }
    
    /// 删除已下载歌曲
    /// - Parameter song: 要删除的歌曲
    func deleteDownload(song: Song) {
        // 删除本地文件
        let fileUrl = getLocalFileUrl(for: song)
        try? fileManager.removeItem(at: fileUrl)
        
        // 从完成列表移除
        completedDownloads.removeAll { $0.song.id == song.id }
        
        // 从存储中移除
        StorageManager.shared.removeDownloadedSong(song)
    }
    
    // MARK: - 下载处理
    
    /// 处理下载队列
    private func processQueue() {
        // 检查是否已有正在下载的任务
        guard currentDownload == nil else { return }
        
        // 获取下一个等待中的任务
        guard let nextTaskIndex = downloadQueue.firstIndex(where: { $0.state == .waiting }) else {
            return
        }
        
        // 开始下载
        downloadQueue[nextTaskIndex].state = .downloading(progress: 0)
        currentDownload = downloadQueue[nextTaskIndex]
        isDownloading = true
        
        // 模拟下载（实际应使用真实下载逻辑）
        simulateDownload(taskIndex: nextTaskIndex)
    }
    
    /// 模拟下载过程
    private func simulateDownload(taskIndex: Int) {
        Task {
            var progress: Double = 0
            
            while progress < 1.0 {
                // 检查任务是否被取消或暂停
                guard taskIndex < downloadQueue.count,
                      case .downloading = downloadQueue[taskIndex].state else {
                    return
                }
                
                // 模拟下载进度
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                progress += 0.05
                
                // 更新进度
                downloadQueue[taskIndex].progress = min(progress, 1.0)
                downloadQueue[taskIndex].state = .downloading(progress: progress)
                currentDownload = downloadQueue[taskIndex]
                
                updateTotalProgress()
            }
            
            // 下载完成
            completeDownload(taskIndex: taskIndex)
        }
    }
    
    /// 完成下载
    private func completeDownload(taskIndex: Int) {
        guard taskIndex < downloadQueue.count else { return }
        
        var task = downloadQueue[taskIndex]
        task.state = .completed
        task.progress = 1.0
        task.localUrl = getLocalFileUrl(for: task.song)
        
        // 移动到完成列表
        completedDownloads.append(task)
        downloadQueue.remove(at: taskIndex)
        
        // 保存到存储
        StorageManager.shared.addDownloadedSong(task.song)
        
        // 重置当前下载
        currentDownload = nil
        isDownloading = false
        
        // 处理下一个任务
        processQueue()
    }
    
    /// 更新总进度
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
    
    /// 检查歌曲是否已下载
    /// - Parameter song: 要检查的歌曲
    /// - Returns: 是否已下载
    func isDownloaded(_ song: Song) -> Bool {
        StorageManager.shared.isSongDownloaded(song)
    }
    
    /// 获取下载状态
    /// - Parameter song: 歌曲
    /// - Returns: 下载状态
    func getDownloadState(for song: Song) -> DownloadState {
        // 检查是否已完成
        if isDownloaded(song) {
            return .completed
        }
        
        // 检查是否在队列中
        if let task = downloadQueue.first(where: { $0.song.id == song.id }) {
            return task.state
        }
        
        return .idle
    }
    
    /// 获取本地文件 URL
    /// - Parameter song: 歌曲
    /// - Returns: 本地文件 URL
    func getLocalFileUrl(for song: Song) -> URL {
        downloadDirectory.appendingPathComponent("\(song.id.uuidString).mp3")
    }
    
    /// 检查是否连接 WiFi
    private func isOnWiFi() -> Bool {
        // 简化实现，实际应使用 Network 框架
        return true
    }
    
    /// 获取已下载文件大小
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
    
    /// 格式化文件大小
    static func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
