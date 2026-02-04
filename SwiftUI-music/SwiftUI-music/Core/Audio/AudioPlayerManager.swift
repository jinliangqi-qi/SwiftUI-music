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

// MARK: - 音频播放管理器
/// 全局音频播放管理器 - 单例模式
/// 负责管理所有音频播放相关功能
@MainActor
final class AudioPlayerManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = AudioPlayerManager()
    
    // MARK: - Published 属性（UI 绑定）
    /// 当前播放状态
    @Published var playerState: PlayerState = .stopped
    
    /// 当前播放歌曲
    @Published var currentSong: Song?
    
    /// 播放队列
    @Published var playQueue: [Song] = []
    
    /// 当前播放索引
    @Published var currentIndex: Int = 0
    
    /// 当前播放时间（秒）
    @Published var currentTime: Double = 0
    
    /// 总时长（秒）
    @Published var duration: Double = 0
    
    /// 播放进度（0.0 - 1.0）
    @Published var progress: Double = 0
    
    /// 是否正在播放
    @Published var isPlaying: Bool = false
    
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
    
    // MARK: - 内部属性（供扩展访问）
    /// AVPlayer 实例
    var player: AVPlayer?
    
    /// 播放器观察者（用于清理）
    var timeObserver: Any?
    
    /// Combine 订阅集合
    var cancellables = Set<AnyCancellable>()
    
    /// 随机播放队列索引
    var shuffledIndices: [Int] = []
    
    /// 是否已配置音频会话
    var isAudioSessionConfigured = false
    
    /// 模拟播放计时器
    var simulatedTimer: Timer?
    
    // MARK: - 初始化
    private init() {
        // 延迟初始化音频会话，避免模拟器崩溃
    }
    
    // MARK: - 音频会话配置
    /// 配置音频会话，支持后台播放（延迟初始化）
    func setupAudioSessionIfNeeded() {
        guard !isAudioSessionConfigured else { return }
        
        #if !targetEnvironment(simulator)
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
        print("⚠️ 模拟器环境，跳过音频会话配置")
        isAudioSessionConfigured = true
        #endif
    }
    
    // MARK: - 远程控制中心配置
    /// 配置锁屏和控制中心的播放控制（仅真机）
    private func setupRemoteCommandCenter() {
        #if targetEnvironment(simulator)
        return
        #else
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.resume() }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.playNext() }
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.playPrevious() }
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in self?.seek(to: event.positionTime) }
            return .success
        }
        #endif
    }
    
    // MARK: - 模拟播放
    
    /// 模拟播放（当没有真实音频 URL 时使用）
    func simulatePlayback(song: Song) {
        playerState = .playing
        isPlaying = true
        duration = song.duration ?? 210
        currentTime = 0
        startSimulatedTimer()
        updateNowPlayingInfo()
        checkIfSongIsLiked()
    }
    
    func startSimulatedTimer() {
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
    
    func stopSimulatedTimer() {
        simulatedTimer?.invalidate()
        simulatedTimer = nil
    }
    
    func generateShuffledIndices() {
        shuffledIndices = Array(0..<playQueue.count).shuffled()
    }
    
    // MARK: - 收藏功能
    
    func checkIfSongIsLiked() {
        guard let song = currentSong else {
            isCurrentSongLiked = false
            return
        }
        isCurrentSongLiked = StorageManager.shared.isSongLiked(song)
    }
    
    func toggleLike() {
        guard let song = currentSong else { return }
        if isCurrentSongLiked {
            StorageManager.shared.removeLikedSong(song)
        } else {
            StorageManager.shared.addLikedSong(song)
        }
        isCurrentSongLiked.toggle()
    }
    
    // MARK: - 播放器内部方法
    
    func setupTimeObserver() {
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
    
    func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
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
        case .unknown:
            playerState = .loading
        @unknown default:
            break
        }
    }
    
    func handlePlaybackEnded() {
        switch repeatMode {
        case .one:
            seek(to: 0)
            resume()
        case .all:
            playNext()
        case .none:
            if currentIndex < playQueue.count - 1 {
                playNext()
            } else {
                stop()
            }
        }
    }
    
    func updateNowPlayingInfo() {
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
    static func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
