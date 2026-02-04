//
//  PlaylistCardView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct PlaylistCardView: View {
    let playlist: Playlist
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 图片
            CachedImageView(urlString: playlist.imageUrl)
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 180, height: 160) // 确保图片高度一致
                .cornerRadius(12) // 调整圆角大小与图片一致
                .clipped() // 确保内容不会溢出圆角边界
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // 轻微的阴影效果
            
            // 底部文字信息
            VStack(alignment: .leading, spacing: 2) { // 减小文字间距
                Text(playlist.title)
                    .font(.system(size: 14, weight: .medium)) // 调整字体粗细
                    .foregroundColor(.white)
                    .lineLimit(1) // 限制为一行
                
                Text("\(playlist.songCount)首歌")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
            }
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 180)
        .cornerRadius(12)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(MusicData.playlists) { playlist in
            PlaylistCardView(playlist: playlist)
        }
    }
    .padding()
    .background(Color(.systemBackground))
}
