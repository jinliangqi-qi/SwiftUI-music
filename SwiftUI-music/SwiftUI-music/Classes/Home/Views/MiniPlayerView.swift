//
//  MiniPlayerView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct MiniPlayerView: View {
    let song: Song
    @State private var isPlaying: Bool = true
    @State private var showPlayerView: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧：歌曲信息
            HStack(spacing: 12) {
                // 歌曲封面
                CachedImageView(urlString: song.imageUrl, cornerRadius: 6)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shineEffect() // 添加闪光效果
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(song.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
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
                        isPlaying.toggle()
                    }
                }) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        )
                }
                
                // 下一首按钮
                Button(action: {
                    // 下一首歌曲的操作
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
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
        .fullScreenCover(isPresented: $showPlayerView) {
            PlayerView(song: song)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        MiniPlayerView(song: MusicData.currentlyPlaying)
    }
    .background(Color(.systemBackground))
}
