//
//  RecentlyPlayedItemView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct RecentlyPlayedItemView: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 12) {
            // 歌曲封面
            CachedImageView(urlString: song.imageUrl, cornerRadius: 8)
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 歌曲信息
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(song.artist)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 播放按钮
            Button(action: {
                // 播放歌曲的操作
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    )
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 0) {
        ForEach(MusicData.recentlyPlayed) { song in
            RecentlyPlayedItemView(song: song)
            Divider()
        }
    }
    .padding()
    .background(Color(.systemBackground))
}
