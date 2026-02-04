//
//  MiniPlayerView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  迷你播放器视图 - 集成 AudioPlayerManager
//

import SwiftUI

struct MiniPlayerView: View {
    // 使用全局播放器管理器
    @StateObject private var playerManager = AudioPlayerManager.shared
    @State private var showPlayerView: Bool = false
    
    // 当前显示的歌曲（优先使用播放器管理器的歌曲）
    private var displaySong: Song {
        playerManager.currentSong ?? MusicData.currentlyPlaying
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧：歌曲信息
            HStack(spacing: 12) {
                // 歌曲封面
                CachedImageView(urlString: displaySong.imageUrl, cornerRadius: 6)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shineEffect() // 添加闪光效果
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(displaySong.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(displaySong.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .onTapGesture {
                withAnimation(AnimationUtils.springAnimation) {
                    showPlayerView = true
                }
            }
            
            Spacer()
            
            // 右侧：播放控制
            HStack(spacing: 16) {
                // 播放/暂停按钮
                Button(action: {
                    withAnimation(AnimationUtils.easeAnimation) {
                        playerManager.togglePlayPause()
                    }
                }) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        )
                }
                
                // 下一首按钮
                Button(action: {
                    playerManager.playNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            // 进度条
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: geometry.size.width * playerManager.progress, height: 2)
            }
            .frame(height: 2),
            alignment: .top
        )
        .fullScreenCover(isPresented: $showPlayerView) {
            PlayerView(song: displaySong)
        }
        .onAppear {
            // 如果没有当前歌曲，初始化播放队列
            if playerManager.currentSong == nil {
                playerManager.playQueue(MusicData.recentlyPlayed, startIndex: 0)
                playerManager.pause() // 初始暂停
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView()
    }
    .background(Color(.systemBackground))
}
