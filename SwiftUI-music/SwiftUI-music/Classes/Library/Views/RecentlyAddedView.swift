//
//  RecentlyAddedView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct RecentlyAddedView: View {
    // 使用MusicData中的最近播放数据作为示例
    private let recentSongs = MusicData.recentlyPlayed
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("最近添加")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            // 歌曲列表
            VStack(spacing: 16) {
                ForEach(recentSongs) { song in
                    SongRowView(song: song)
                }
            }
        }
    }
}

// 歌曲行视图
struct SongRowView: View {
    let song: Song
    
    var body: some View {
        HStack(spacing: 12) {
            // 歌曲封面
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray5))
                    .frame(width: 48, height: 48)
                
                // 实际项目中应使用CachedImageView加载网络图片
                // 这里使用占位符
                Image(systemName: "music.note")
                    .foregroundColor(.gray)
            }
            
            // 歌曲信息
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.system(size: 16, weight: .medium))
                
                Text(song.artist)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 更多按钮
            Button(action: {
                // 显示更多选项
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    RecentlyAddedView()
        .padding()
        .background(Color(.systemBackground))
}
