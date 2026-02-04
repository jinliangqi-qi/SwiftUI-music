//
//  RecentActivitiesView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct RecentActivitiesView: View {
    let activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("最近活动")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(activities) { activity in
                    ActivityItemView(activity: activity)
                }
            }
        }
    }
}

struct ActivityItemView: View {
    let activity: Activity
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                // 用户头像
                Circle()
                    .fill(Color.purple)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("小")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // 活动描述
                    HStack(spacing: 4) {
                        Text("小明")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(activityDescription)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                    }
                    
                    // 活动时间
                    Text(activity.time)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    // 活动内容
                    ActivityContentView(activity: activity)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // 根据活动类型生成描述文本
    private var activityDescription: String {
        switch activity.type {
        case .addedToFavorites:
            return "添加了新歌曲到收藏"
        case .createdPlaylist:
            return "创建了新歌单"
        case .followedArtist:
            return "关注了新艺术家"
        case .sharedSong:
            return "分享了一首歌曲"
        }
    }
}

struct ActivityContentView: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // 内容图片
            CachedImageView(urlString: activity.content.imageUrl, cornerRadius: 6)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            VStack(alignment: .leading, spacing: 2) {
                // 内容标题
                Text(activity.content.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                // 内容描述
                Text(contentDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // 根据内容类型生成描述文本
    private var contentDescription: String {
        if let song = activity.content as? Song {
            return song.artist
        } else if let playlist = activity.content as? Playlist {
            return "\(playlist.songCount)首歌"
        } else {
            return ""
        }
    }
}

#Preview {
    RecentActivitiesView(activities: [
        Activity(
            type: .addedToFavorites,
            time: "2分钟前",
            content: Song(
                title: "夜曲",
                artist: "周杰伦",
                imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
            )
        ),
        Activity(
            type: .createdPlaylist,
            time: "昨天 14:32",
            content: Playlist(
                title: "我的周末歌单",
                songCount: 25,
                imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
            )
        )
    ])
    .padding()
    .background(Color(.systemBackground))
}
