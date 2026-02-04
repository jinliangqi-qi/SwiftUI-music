//
//  ProfileView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  个人资料视图 - 支持 iPhone/iPad 响应式布局
//

import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(\.isWideLayout) private var isWideLayout
    
    // 用户数据
    let username = "小明"
    let userHandle = "@xiaoming"
    let avatarUrl = "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"
    let backgroundUrl = "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
    
    // 用户统计数据
    let stats = UserStats(
        favorites: 428,
        playlists: 32,
        following: 286,
        followers: 142
    )
    
    // 收听统计数据
    let listeningStats = ListeningStats(
        weeklyTime: "12小时42分钟",
        dailyData: [
            DailyListening(day: "一", percentage: 0.3),
            DailyListening(day: "二", percentage: 0.45),
            DailyListening(day: "三", percentage: 0.6),
            DailyListening(day: "四", percentage: 0.4),
            DailyListening(day: "五", percentage: 0.75),
            DailyListening(day: "六", percentage: 0.9),
            DailyListening(day: "日", percentage: 0.65)
        ]
    )
    
    // 喜爱的艺术家
    let favoriteArtists = [
        Artist(name: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDF8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "林俊杰", imageUrl: "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "Taylor Swift", imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D"),
        Artist(name: "Beyond", imageUrl: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDB8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "张学友", imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fHBvcnRyYWl0fGVufDB8fDB8fHww")
    ]
    
    // 最近活动
    let recentActivities = [
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
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 用户信息头部（背景图延伸到状态栏）
                ProfileHeaderView(
                    username: username,
                    userHandle: userHandle,
                    avatarUrl: avatarUrl,
                    backgroundUrl: backgroundUrl
                )
                
                // 宽屏使用两列布局，其他使用单列
                if isWideLayout {
                    wideProfileContent
                } else {
                    compactProfileContent
                }
            }
            .frame(maxWidth: isWideLayout ? 900 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea(edges: .top) // 让内容延伸到状态栏区域
    }
    
    // MARK: - 紧凑布局（iPhone 和 iPad 竖屏）
    private var compactProfileContent: some View {
        VStack(spacing: 0) {
            // 用户数据统计
            UserStatsView(stats: stats)
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            // 收听统计
            ListeningStatsView(stats: listeningStats)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            // 喜爱的艺术家
            FavoriteArtistsView(artists: favoriteArtists)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            // 最近活动
            RecentActivitiesView(activities: recentActivities)
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
        }
    }
    
    // MARK: - 宽屏布局（iPad 横屏，两列）
    private var wideProfileContent: some View {
        VStack(spacing: 0) {
            // 用户数据统计
            UserStatsView(stats: stats)
                .padding(.top, 24)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
            
            // 两列布局：左侧收听统计，右侧最近活动
            HStack(alignment: .top, spacing: 24) {
                // 左侧
                VStack(spacing: 16) {
                    ListeningStatsView(stats: listeningStats)
                    FavoriteArtistsView(artists: favoriteArtists)
                }
                .frame(maxWidth: .infinity)
                
                // 右侧
                RecentActivitiesView(activities: recentActivities)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 140)
        }
    }
}

#Preview {
    ProfileView()
}
