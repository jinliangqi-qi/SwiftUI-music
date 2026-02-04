//
//  MusicModels.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  音乐数据模型 - 兼容 iOS 18+ / Swift 6
//

import Foundation

// MARK: - 推荐卡片模型
/// 首页推荐卡片
struct RecommendationCard: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let imageUrl: String
    let gradientColors: [String] // 渐变色
    
    init(id: UUID = UUID(), title: String, description: String, imageUrl: String, gradientColors: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.gradientColors = gradientColors
    }
}

// MARK: - 歌单模型
/// 歌单信息
struct Playlist: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String
    let songCount: Int
    let imageUrl: String
    
    init(id: UUID = UUID(), title: String, songCount: Int, imageUrl: String) {
        self.id = id
        self.title = title
        self.songCount = songCount
        self.imageUrl = imageUrl
    }
}

// MARK: - 歌曲模型
/// 歌曲信息
struct Song: Identifiable, Codable, Sendable, Equatable {
    let id: UUID
    let title: String
    let artist: String
    let imageUrl: String
    var isPlaying: Bool
    
    // 扩展属性
    var album: String?           // 专辑名
    var audioUrl: String?        // 音频 URL
    var duration: Double?        // 时长（秒）
    var lyrics: String?          // 歌词
    var genre: String?           // 流派
    var releaseDate: String?     // 发行日期
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        imageUrl: String,
        isPlaying: Bool = false,
        album: String? = nil,
        audioUrl: String? = nil,
        duration: Double? = nil,
        lyrics: String? = nil,
        genre: String? = nil,
        releaseDate: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.imageUrl = imageUrl
        self.isPlaying = isPlaying
        self.album = album
        self.audioUrl = audioUrl
        self.duration = duration
        self.lyrics = lyrics
        self.genre = genre
        self.releaseDate = releaseDate
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 模拟数据
/// 模拟数据类 - 使用 @MainActor 和 nonisolated 确保线程安全
@MainActor
final class MusicData: Sendable {
    // 推荐卡片数据
    nonisolated static let recommendations: [RecommendationCard] = [
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
    nonisolated static let playlists: [Playlist] = [
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
    nonisolated static let recentlyPlayed: [Song] = [
        Song(
            title: "夜曲",
            artist: "周杰伦",
            imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D",
            album: "十一月的萧邦",
            audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            duration: 210,
            genre: "流行",
            releaseDate: "2005"
        ),
        Song(
            title: "浮夸",
            artist: "陈奕迅",
            imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bXVzaWN8ZW58MHx8MHx8fDA%3D",
            album: "U87",
            audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            duration: 243,
            genre: "粤语流行",
            releaseDate: "2005"
        ),
        Song(
            title: "海阔天空",
            artist: "Beyond",
            imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D",
            album: "乐与怒",
            audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            duration: 315,
            genre: "摇滚",
            releaseDate: "1993"
        )
    ]
    
    // 当前播放的歌曲
    nonisolated static let currentlyPlaying = Song(
        title: "夜曲",
        artist: "周杰伦",
        imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D",
        album: "十一月的萧邦",
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        duration: 210,
        genre: "流行",
        releaseDate: "2005"
    )
    
    // 全部歌曲库（用于搜索）
    nonisolated static let allSongs: [Song] = [
        Song(title: "夜曲", artist: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500", album: "十一月的萧邦", duration: 210, genre: "流行"),
        Song(title: "浮夸", artist: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500", album: "U87", duration: 243, genre: "粤语流行"),
        Song(title: "海阔天空", artist: "Beyond", imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500", album: "乐与怒", duration: 315, genre: "摇滚"),
        Song(title: "稻香", artist: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500", album: "魔杰座", duration: 223, genre: "流行"),
        Song(title: "爱情转移", artist: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500", album: "What's Going On", duration: 268, genre: "流行"),
        Song(title: "爱在西元前", artist: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=500", album: "Jay", duration: 235, genre: "流行"),
        Song(title: "爱如潮水", artist: "张信哲", imageUrl: "https://images.unsplash.com/photo-1485579149621-3123dd979885?w=500", album: "挚爱", duration: 258, genre: "情歌"),
        Song(title: "光辉岁月", artist: "Beyond", imageUrl: "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=500", album: "命运派对", duration: 296, genre: "摇滚"),
        Song(title: "江南", artist: "林俊杰", imageUrl: "https://images.unsplash.com/photo-1499415479124-43c32433a620?w=500", album: "第二天堂", duration: 262, genre: "流行"),
        Song(title: "可惜不是你", artist: "梁静茹", imageUrl: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500", album: "丝路", duration: 285, genre: "情歌")
    ]
}
