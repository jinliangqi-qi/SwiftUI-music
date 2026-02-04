//
//  MusicModels.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import Foundation

// 推荐卡片模型
struct RecommendationCard: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageUrl: String
    let gradientColors: [String] // 渐变色
}

// 歌单模型
struct Playlist: Identifiable {
    let id = UUID()
    let title: String
    let songCount: Int
    let imageUrl: String
}

// 歌曲模型
struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let imageUrl: String
    let isPlaying: Bool = false
}

// 模拟数据
class MusicData {
    // 推荐卡片数据
    static let recommendations: [RecommendationCard] = [
        RecommendationCard(
            title: "今日热门",
            description: "根据你的口味推荐",
            imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D",
            gradientColors: ["purple", "indigo"]
        ),
        RecommendationCard(
            title: "新歌速递",
            description: "最新发行的热门单曲",
            imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bXVzaWN8ZW58MHx8MHx8fDA%3D",
            gradientColors: ["red", "pink"]
        ),
        RecommendationCard(
            title: "心情良好",
            description: "提升你的心情",
            imageUrl: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fG11c2ljfGVufDB8fDB8fHww",
            gradientColors: ["yellow", "orange"]
        ),
        RecommendationCard(
            title: "放松时光",
            description: "轻松愉快的旋律",
            imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fG11c2ljfGVufDB8fDB8fHww",
            gradientColors: ["green", "teal"]
        )
    ]
    
    // 热门歌单数据
    static let playlists: [Playlist] = [
        Playlist(
            title: "华语经典",
            songCount: 120,
            imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
        ),
        Playlist(
            title: "流行热歌",
            songCount: 98,
            imageUrl: "https://images.unsplash.com/photo-1485579149621-3123dd979885?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fG11c2ljfGVufDB8fDB8fHww"
        ),
        Playlist(
            title: "嘻哈说唱",
            songCount: 76,
            imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bXVzaWN8ZW58MHx8MHx8fDA%3D"
        ),
        Playlist(
            title: "独立民谣",
            songCount: 135,
            imageUrl: "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fG11c2ljfGVufDB8fDB8fHww"
        )
    ]
    
    // 最近播放的歌曲数据
    static let recentlyPlayed: [Song] = [
        Song(
            title: "夜曲",
            artist: "周杰伦",
            imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
        ),
        Song(
            title: "浮夸",
            artist: "陈奕迅",
            imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bXVzaWN8ZW58MHx8MHx8fDA%3D"
        ),
        Song(
            title: "海阔天空",
            artist: "Beyond",
            imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
        )
    ]
    
    // 当前播放的歌曲
    static let currentlyPlaying = Song(
        title: "夜曲",
        artist: "周杰伦",
        imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
    )
}
