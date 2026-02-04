//
//  AudioPlayerManager.swift
//  SwiftUI-music
//
//  音频播放引擎 - 使用 AVFoundation 实现真实音频播放
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

// MARK: - 播放状态枚举
/// 播放器状态
enum PlayerState: Sendable {
    case stopped    // 停止
    case playing    // 播放中
    case paused     // 暂停
    case loading    // 加载中
    case error      // 错误
}

// MARK: - 播放模式枚举
/// 播放循环模式
enum RepeatMode: Int, Sendable, CaseIterable {
    case none = 0   // 不循环
    case one = 1    // 单曲循环
    case all = 2    // 列表循环
    
    /// 切换到下一个模式
    var next: RepeatMode {
        RepeatMode(rawValue: (rawValue + 1) % RepeatMode.allCases.count) ?? .none
    }
}

// MARK: - 音频播放管理器
/// 全局音频播放管理器 - 单例模式
/// 负责管理所有音频播放相关功能
@MainActor
final class AudioPlayerManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = AudioPlayerManager()
    
    // MARK: - Published 属性（UI 绑定）
    /// 当前播放状态
    @Published private(set) var playerState: PlayerState = .stopped
    
    /// 当前播放歌曲
    @Published var currentSong: Song?
    
    /// 播放队列
    @Published var playQueue: [Song] = []
    
    /// 当前播放索引
    @Published private(set) var currentIndex: Int = 0
    
    /// 当前播放时间（秒）
    @Published private(set) var currentTime: Double = 0
    
    /// 总时长（秒）
    @Published private(set) var duration: Double = 0
    
    /// 播放进度（0.0 - 1.0）
    @Published private(set) var progress: Double = 0
    
    /// 是否正在播放
    @Published private(set) var isPlaying: Bool = false
    
    /// 循环模式
    @Published var repeatMode: RepeatMode = .none
    
    /// 是否随机播放
    @Published var isShuffleEnabled: Bool = false
    
    /// 音量（0.0 - 1.0）
    @Published var volume: Float = 1.0 {
        didSet {
            player?.volume = volume
        }
    }
    
    /// 是否已喜欢当前歌曲
    @Published var isCurrentSongLiked: Bool = false
    
    // MARK: - 私有属性
    /// AVPlayer 实例
    private var player: AVPlayer?
    
    /// 播放器观察者（用于清理）
    private var timeObserver: Any?
    
    /// Combine 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    /// 随机播放队列索引
    private var shuffledIndices: [Int] = []
    
    /// 是否已配置音频会话
    private var isAudioSessionConfigured = false
    
    // MARK: - 初始化
    private init() {
        // 延迟初始化音频会话，避免模拟器崩溃
        // setupAudioSession() 和 setupRemoteCommandCenter() 将在首次播放时调用
    }
    
    // 注意：由于 Swift 6 的并发限制，deinit 不能访问 @MainActor 隔离的属性
    // 对于单例模式，deinit 通常不会被调用，所以这里移除 deinit
    
    // MARK: - 音频会话配置
    /// 配置音频会话，支持后台播放（延迟初始化）
    private func setupAudioSessionIfNeeded() {
        guard !isAudioSessionConfigured else { return }
        
        #if !targetEnvironment(simulator)
        // 真机上配置音频会话
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
            setupRemoteCommandCenter()
            isAudioSessionConfigured = true
            print("✅ 音频会话配置成功")
        } catch {
            print("❌ 音频会话配置失败: \(error.localizedDescription)")
        }
        #else
        // 模拟器上跳过音频会话配置，避免崩溃
        print("⚠️ 模拟器环境，跳过音频会话配置")
        isAudioSessionConfigured = true
        #endif
    }
    
    /// 配置音频会话（旧方法保留兼容性）
    private func setupAudioSession() {
        setupAudioSessionIfNeeded()
    }
    
    // MARK: - 远程控制中心配置
    /// 配置锁屏和控制中心的播放控制（仅真机）
    private func setupRemoteCommandCenter() {
        #if targetEnvironment(simulator)
        // 模拟器上跳过，避免崩溃
        return
        #else
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 播放命令
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }
        
        // 暂停命令
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }
        
        // 下一首命令
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playNext()
            }
            return .success
        }
        
        // 上一首命令
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playPrevious()
            }
            return .success
        }
        
        // 进度跳转命令
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                self?.seek(to: event.positionTime)
            }
            return .success
        }
        #endif
    }
    
    // MARK: - 播放控制
    
    /// 播放指定歌曲
    /// - Parameter song: 要播放的歌曲
    func play(song: Song) {
        // 延迟初始化音频会话（首次播放时）
        setupAudioSessionIfNeeded()
        
        // 更新当前歌曲
        currentSong = song
        playerState = .loading
        
        // 检查歌曲是否在队列中
        if let index = playQueue.firstIndex(where: { $0.id == song.id }) {
            currentIndex = index
        } else {
            // 添加到队列
            playQueue.append(song)
            currentIndex = playQueue.count - 1
        }
        
        // 检查是否有有效的音频 URL
        guard let audioUrl = song.audioUrl, let url = URL(string: audioUrl) else {
            // 使用模拟播放（演示用）
            simulatePlayback(song: song)
            return
        }
        
        // 创建播放器项目
        let playerItem = AVPlayerItem(url: url)
        
        // 监听播放状态
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                Task { @MainActor in
                    self?.handlePlayerItemStatus(status)
                }
            }
            .store(in: &cancellables)
        
        // 监听播放结束
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handlePlaybackEnded()
                }
            }
            .store(in: &cancellables)
        
        // 替换或创建播放器
        if let existingPlayer = player {
            existingPlayer.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
            player?.volume = volume
        }
        
        // 开始播放
        player?.play()
        setupTimeObserver()
        updateNowPlayingInfo()
        
        // 检查是否已收藏
        checkIfSongIsLiked()
    }
    
    /// 模拟播放（当没有真实音频 URL 时使用）
    private func simulatePlayback(song: Song) {
        playerState = .playing
        isPlaying = true
        duration = song.duration ?? 210 // 默认 3:30
        currentTime = 0
        
        // 启动模拟计时器
        startSimulatedTimer()
        updateNowPlayingInfo()
        checkIfSongIsLiked()
    }
    
    /// 模拟播放计时器
    private var simulatedTimer: Timer?
    
    private func startSimulatedTimer() {
        simulatedTimer?.invalidate()
        simulatedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, self.isPlaying else { return }
                self.currentTime += 1
                self.progress = self.currentTime / max(self.duration, 1)
                
                if self.currentTime >= self.duration {
                    self.handlePlaybackEnded()
                }
            }
        }
    }
    
    private func stopSimulatedTimer() {
        simulatedTimer?.invalidate()
        simulatedTimer = nil
    }
    
    /// 播放队列中的歌曲
    /// - Parameter songs: 歌曲列表
    /// - Parameter startIndex: 起始索引
    func playQueue(_ songs: [Song], startIndex: Int = 0) {
        playQueue = songs
        currentIndex = startIndex
        
        if isShuffleEnabled {
            generateShuffledIndices()
        }
        
        if let song = songs[safe: startIndex] {
            play(song: song)
        }
    }
    
    /// 继续播放
    func resume() {
        if player != nil {
            player?.play()
        } else {
            startSimulatedTimer()
        }
        playerState = .playing
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    /// 暂停播放
    func pause() {
        player?.pause()
        stopSimulatedTimer()
        playerState = .paused
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    /// 切换播放/暂停
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            if currentSong != nil {
                resume()
            } else if let firstSong = playQueue.first {
                play(song: firstSong)
            }
        }
    }
    
    /// 停止播放
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        stopSimulatedTimer()
        playerState = .stopped
        isPlaying = false
        currentTime = 0
        progress = 0
    }
    
    /// 播放下一首
    func playNext() {
        guard !playQueue.isEmpty else { return }
        
        let nextIndex: Int
        if isShuffleEnabled && !shuffledIndices.isEmpty {
            if let currentShuffleIndex = shuffledIndices.firstIndex(of: currentIndex) {
                let nextShuffleIndex = (currentShuffleIndex + 1) % shuffledIndices.count
                nextIndex = shuffledIndices[nextShuffleIndex]
            } else {
                nextIndex = shuffledIndices.first ?? 0
            }
        } else {
            nextIndex = (currentIndex + 1) % playQueue.count
        }
        
        currentIndex = nextIndex
        if let song = playQueue[safe: nextIndex] {
            play(song: song)
        }
    }
    
    /// 播放上一首
    func playPrevious() {
        guard !playQueue.isEmpty else { return }
        
        // 如果播放超过 3 秒，重新播放当前歌曲
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        
        let prevIndex: Int
        if isShuffleEnabled && !shuffledIndices.isEmpty {
            if let currentShuffleIndex = shuffledIndices.firstIndex(of: currentIndex) {
                let prevShuffleIndex = (currentShuffleIndex - 1 + shuffledIndices.count) % shuffledIndices.count
                prevIndex = shuffledIndices[prevShuffleIndex]
            } else {
                prevIndex = shuffledIndices.last ?? 0
            }
        } else {
            prevIndex = (currentIndex - 1 + playQueue.count) % playQueue.count
        }
        
        currentIndex = prevIndex
        if let song = playQueue[safe: prevIndex] {
            play(song: song)
        }
    }
    
    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    func seek(to time: Double) {
        let clampedTime = max(0, min(time, duration))
        
        if player != nil {
            let cmTime = CMTime(seconds: clampedTime, preferredTimescale: 600)
            player?.seek(to: cmTime)
        }
        
        currentTime = clampedTime
        progress = clampedTime / max(duration, 1)
        updateNowPlayingInfo()
    }
    
    /// 跳转到指定进度
    /// - Parameter progress: 进度（0.0 - 1.0）
    func seek(toProgress progress: Double) {
        let targetTime = progress * duration
        seek(to: targetTime)
    }
    
    // MARK: - 播放模式控制
    
    /// 切换循环模式
    func toggleRepeatMode() {
        repeatMode = repeatMode.next
    }
    
    /// 切换随机播放
    func toggleShuffle() {
        isShuffleEnabled.toggle()
        if isShuffleEnabled {
            generateShuffledIndices()
        }
    }
    
    /// 生成随机播放索引
    private func generateShuffledIndices() {
        shuffledIndices = Array(0..<playQueue.count).shuffled()
    }
    
    // MARK: - 收藏功能
    
    /// 检查当前歌曲是否已收藏
    private func checkIfSongIsLiked() {
        guard let song = currentSong else {
            isCurrentSongLiked = false
            return
        }
        isCurrentSongLiked = StorageManager.shared.isSongLiked(song)
    }
    
    /// 切换收藏状态
    func toggleLike() {
        guard let song = currentSong else { return }
        
        if isCurrentSongLiked {
            StorageManager.shared.removeLikedSong(song)
        } else {
            StorageManager.shared.addLikedSong(song)
        }
        
        isCurrentSongLiked.toggle()
    }
    
    // MARK: - 私有方法
    
    /// 设置时间观察者
    private func setupTimeObserver() {
        removeTimeObserver()
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.currentTime = time.seconds
                
                if let duration = self.player?.currentItem?.duration.seconds, duration.isFinite {
                    self.duration = duration
                    self.progress = time.seconds / duration
                }
            }
        }
    }
    
    /// 移除时间观察者
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    /// 处理播放项目状态变化
    private func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            playerState = .playing
            isPlaying = true
            if let duration = player?.currentItem?.duration.seconds, duration.isFinite {
                self.duration = duration
            }
        case .failed:
            playerState = .error
            isPlaying = false
            print("❌ 播放失败")
        case .unknown:
            playerState = .loading
        @unknown default:
            break
        }
    }
    
    /// 处理播放结束
    private func handlePlaybackEnded() {
        switch repeatMode {
        case .one:
            // 单曲循环
            seek(to: 0)
            resume()
        case .all:
            // 列表循环
            playNext()
        case .none:
            // 不循环，播放下一首或停止
            if currentIndex < playQueue.count - 1 {
                playNext()
            } else {
                stop()
            }
        }
    }
    
    /// 更新锁屏/控制中心信息
    private func updateNowPlayingInfo() {
        // 模拟器上跳过，避免崩溃
        #if targetEnvironment(simulator)
        return
        #else
        guard let song = currentSong else { return }
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        
        // 异步加载封面图片
        if let imageUrl = URL(string: song.imageUrl) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: imageUrl),
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        #endif
    }
    
    // MARK: - 辅助方法
    
    /// 格式化时间显示
    /// - Parameter seconds: 秒数
    /// - Returns: 格式化后的时间字符串（如 "3:45"）
    static func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - 数组安全索引扩展
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
