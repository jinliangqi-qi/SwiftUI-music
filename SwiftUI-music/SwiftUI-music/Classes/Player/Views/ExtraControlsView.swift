//
//  ExtraControlsView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct ExtraControlsView: View {
    @Binding var isLiked: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // 音量按钮
            Button(action: {
                // 显示音量控制
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 18))
                        .opacity(0.7)
                    
                    Text("音量")
                        .font(.system(size: 12))
                        .opacity(0.7)
                }
            }
            
            Spacer()
            
            // 喜欢按钮
            Button(action: {
                isLiked.toggle()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isLiked ? .pink : .white.opacity(0.7))
                    
                    Text("喜欢")
                        .font(.system(size: 12))
                        .opacity(0.7)
                }
            }
            
            Spacer()
            
            // 歌词按钮
            Button(action: {
                // 显示完整歌词
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 18))
                        .opacity(0.7)
                    
                    Text("歌词")
                        .font(.system(size: 12))
                        .opacity(0.7)
                }
            }
            
            Spacer()
            
            // 分享按钮
            Button(action: {
                // 分享歌曲
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .opacity(0.7)
                    
                    Text("分享")
                        .font(.system(size: 12))
                        .opacity(0.7)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    ExtraControlsView(isLiked: .constant(false))
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}