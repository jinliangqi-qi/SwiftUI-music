//
//  PlayerView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct PlayerView: View {
    // 当前播放的歌曲
    let song: Song
    
    // 播放状态
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 73 // 1:13 in seconds
    @State private var totalTime: Double = 210 // 3:30 in seconds
    @State private var isShuffle: Bool = false
    @State private var repeatMode: RepeatMode = .none
    @State private var isLiked: Bool = false
    
    // 播放模式枚举
    enum RepeatMode {
        case none, one, all
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
                    PlayerHeaderView(songSource: "来自：\(song.artist) - 热门单曲")
                    
                    // 专辑封面
                    AlbumCoverView(imageUrl: song.imageUrl)
                    
                    // 歌曲信息
                    SongInfoView(title: song.title, artist: song.artist)
                    
                    // 进度条
                    ProgressBarView(
                        currentTime: $currentTime,
                        totalTime: totalTime
                    )
                    
                    // 播放控制
                    PlayerControlsView(
                        isPlaying: $isPlaying,
                        isShuffle: $isShuffle,
                        repeatMode: $repeatMode
                    )
                    
                    // 歌词
                    LyricsView()
                    
                    // 额外控制
                    ExtraControlsView(isLiked: $isLiked)
                    
                    // 音频质量
                    AudioQualityView()
                    
                    // 波形动画
                    WaveAnimationView()
                    
                    Spacer(minLength: 100) // 增加底部间距，为迷你播放器和导航栏留出空间
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // 添加底部padding，确保内容不被遮挡
            }
        }
        .foregroundColor(.white)
    }
}

#Preview {
    PlayerView(song: MusicData.recentlyPlayed[0])
}