//
//  AudioPlayerControls.swift
//  SwiftUI-music
//
//  音频播放控制扩展 - 播放控制相关方法
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer

// MARK: - 播放控制扩展
extension AudioPlayerManager {
    
    /// 播放指定歌曲
    func play(song: Song) {
        setupAudioSessionIfNeeded()
        currentSong = song
        playerState = .loading
        
        if let index = playQueue.firstIndex(where: { $0.id == song.id }) {
            currentIndex = index
        } else {
            playQueue.append(song)
            currentIndex = playQueue.count - 1
        }
        
        guard let audioUrl = song.audioUrl, let url = URL(string: audioUrl) else {
            simulatePlayback(song: song)
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                Task { @MainActor in self?.handlePlayerItemStatus(status) }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in self?.handlePlaybackEnded() }
            }
            .store(in: &cancellables)
        
        if let existingPlayer = player {
            existingPlayer.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
            player?.volume = volume
        }
        
        player?.play()
        setupTimeObserver()
        updateNowPlayingInfo()
        checkIfSongIsLiked()
    }
    
    /// 播放队列中的歌曲
    func playQueue(_ songs: [Song], startIndex: Int = 0) {
        playQueue = songs
        currentIndex = startIndex
        if isShuffleEnabled { generateShuffledIndices() }
        if let song = songs[safe: startIndex] { play(song: song) }
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
        if let song = playQueue[safe: nextIndex] { play(song: song) }
    }
    
    /// 播放上一首
    func playPrevious() {
        guard !playQueue.isEmpty else { return }
        
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
        if let song = playQueue[safe: prevIndex] { play(song: song) }
    }
    
    /// 跳转到指定时间
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
    func seek(toProgress progress: Double) {
        seek(to: progress * duration)
    }
    
    // MARK: - 播放模式控制
    
    func toggleRepeatMode() { repeatMode = repeatMode.next }
    
    func toggleShuffle() {
        isShuffleEnabled.toggle()
        if isShuffleEnabled { generateShuffledIndices() }
    }
}
