//
//  PlayerControlsView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct PlayerControlsView: View {
    @Binding var isPlaying: Bool
    @Binding var isShuffle: Bool
    @Binding var repeatMode: PlayerView.RepeatMode
    
    var body: some View {
        HStack(spacing: 24) {
            // 随机播放按钮
            Button(action: {
                isShuffle.toggle()
            }) {
                Image(systemName: isShuffle ? "shuffle.circle.fill" : "shuffle")
                    .font(.system(size: 22))
                    .opacity(isShuffle ? 1.0 : 0.7)
            }
            
            // 上一首按钮
            Button(action: {
                // 播放上一首歌曲
            }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 24))
            }
            
            // 播放/暂停按钮
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
            }
            
            // 下一首按钮
            Button(action: {
                // 播放下一首歌曲
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
            }
            
            // 循环播放按钮
            Button(action: {
                switch repeatMode {
                case .none: repeatMode = .all
                case .all: repeatMode = .one
                case .one: repeatMode = .none
                }
            }) {
                Group {
                    switch repeatMode {
                    case .none:
                        Image(systemName: "repeat")
                            .opacity(0.7)
                    case .all:
                        Image(systemName: "repeat")
                    case .one:
                        Image(systemName: "repeat.1")
                    }
                }
                .font(.system(size: 22))
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    PlayerControlsView(
        isPlaying: .constant(true),
        isShuffle: .constant(false),
        repeatMode: .constant(.none)
    )
    .padding()
    .background(Color.purple.opacity(0.5))
    .foregroundColor(.white)
}