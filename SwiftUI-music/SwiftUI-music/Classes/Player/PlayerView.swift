//
//  PlayerView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//  全屏播放器视图 - 集成 AudioPlayerManager
//

import SwiftUI

struct PlayerView: View {
    // 传入的歌曲（用于初始化）
    let song: Song
    
    // 使用全局播放器管理器
    @StateObject private var playerManager = AudioPlayerManager.shared
    
    // 环境
    @Environment(\.dismiss) private var dismiss
    
    // 当前显示的歌曲
    private var displaySong: Song {
        playerManager.currentSong ?? song
    }
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 主内容
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部导航
                    PlayerHeaderView(songSource: "来自：\(displaySong.artist) - 热门单曲")
                    
                    // 专辑封面
                    AlbumCoverView(imageUrl: displaySong.imageUrl)
                    
                    // 歌曲信息
                    SongInfoView(title: displaySong.title, artist: displaySong.artist)
                    
                    // 进度条 - 使用播放器管理器的数据
                    ProgressBarView(
                        currentTime: Binding(
                            get: { playerManager.currentTime },
                            set: { playerManager.seek(to: $0) }
                        ),
                        totalTime: playerManager.duration > 0 ? playerManager.duration : (song.duration ?? 210)
                    )
                    
                    // 播放控制 - 使用播放器管理器
                    PlayerControlsView(
                        isPlaying: Binding(
                            get: { playerManager.isPlaying },
                            set: { _ in playerManager.togglePlayPause() }
                        ),
                        isShuffle: Binding(
                            get: { playerManager.isShuffleEnabled },
                            set: { _ in playerManager.toggleShuffle() }
                        ),
                        repeatMode: Binding(
                            get: { playerManager.repeatMode },
                            set: { _ in playerManager.toggleRepeatMode() }
                        ),
                        onPrevious: { playerManager.playPrevious() },
                        onNext: { playerManager.playNext() }
                    )
                    
                    // 歌词
                    LyricsView()
                    
                    // 额外控制 - 使用播放器管理器的收藏状态
                    ExtraControlsView(isLiked: Binding(
                        get: { playerManager.isCurrentSongLiked },
                        set: { _ in playerManager.toggleLike() }
                    ))
                    
                    // 音频质量
                    AudioQualityView()
                    
                    // 波形动画
                    WaveAnimationView()
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .foregroundColor(.white)
        .onAppear {
            // 如果当前没有播放，或者播放的不是传入的歌曲，则开始播放
            if playerManager.currentSong?.id != song.id {
                playerManager.play(song: song)
            }
        }
    }
}

#Preview {
    PlayerView(song: MusicData.recentlyPlayed[0])
}