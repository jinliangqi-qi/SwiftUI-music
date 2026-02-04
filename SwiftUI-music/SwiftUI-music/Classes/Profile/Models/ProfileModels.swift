//
//  ProfileModels.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import Foundation

// 用户统计数据
struct UserStats: Sendable {
    let favorites: Int
    let playlists: Int
    let following: Int
    let followers: Int
}

// 每日收听数据
struct DailyListening: Identifiable, Sendable {
    let id = UUID()
    let day: String
    let percentage: Double // 0.0 - 1.0
}

// 收听统计数据
struct ListeningStats: Sendable {
    let weeklyTime: String
    let dailyData: [DailyListening]
}

// 艺术家模型
struct Artist: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let imageUrl: String
}

// 活动类型
enum ActivityType: Sendable {
    case addedToFavorites
    case createdPlaylist
    case followedArtist
    case sharedSong
}

// 活动内容（可以是歌曲或歌单）
protocol ActivityContent: Sendable {
    var title: String { get }
    var imageUrl: String { get }
}

extension Song: ActivityContent {}
extension Playlist: ActivityContent {}

// 活动模型
struct Activity: Identifiable, Sendable {
    let id = UUID()
    let type: ActivityType
    let time: String
    let content: any ActivityContent
}
