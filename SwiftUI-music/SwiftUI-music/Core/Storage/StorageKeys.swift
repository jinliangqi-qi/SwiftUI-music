//
//  StorageKeys.swift
//  SwiftUI-music
//
//  存储键和音频质量定义
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 存储键定义
/// UserDefaults 存储键枚举
enum StorageKey: String {
    // 用户相关
    case isLoggedIn = "isLoggedIn"
    case currentUser = "currentUser"
    case userToken = "userToken"
    
    // 音乐相关
    case likedSongs = "likedSongs"
    case recentlyPlayed = "recentlyPlayed"
    case searchHistory = "searchHistory"
    case playlists = "playlists"
    case downloadedSongs = "downloadedSongs"
    
    // 设置相关
    case audioQuality = "audioQuality"
    case downloadQuality = "downloadQuality"
    case autoPlayEnabled = "autoPlayEnabled"
    case wifiOnlyDownload = "wifiOnlyDownload"
    case repeatMode = "repeatMode"
    case shuffleEnabled = "shuffleEnabled"
    
    // 播放状态
    case lastPlayedSong = "lastPlayedSong"
    case lastPlaybackPosition = "lastPlaybackPosition"
    case lastPlayQueue = "lastPlayQueue"
}

// MARK: - StorageKey 扩展
extension StorageKey: CaseIterable {
    /// 所有存储键的集合
    static let allCases: [StorageKey] = [
        .isLoggedIn, .currentUser, .userToken,
        .likedSongs, .recentlyPlayed, .searchHistory, .playlists, .downloadedSongs,
        .audioQuality, .downloadQuality, .autoPlayEnabled, .wifiOnlyDownload, .repeatMode, .shuffleEnabled,
        .lastPlayedSong, .lastPlaybackPosition, .lastPlayQueue
    ]
}

// MARK: - 音频质量枚举
/// 音频质量选项
enum AudioQuality: String, Codable, CaseIterable, Sendable {
    case low = "标准"
    case medium = "高清"
    case high = "无损"
    case lossless = "Hi-Res"
    
    var bitrate: Int {
        switch self {
        case .low: return 128
        case .medium: return 256
        case .high: return 320
        case .lossless: return 1411
        }
    }
}

// MARK: - 用户歌单模型
/// 用户创建的歌单
struct UserPlaylist: Identifiable, Codable, Sendable {
    let id: UUID
    var name: String
    var description: String
    var songs: [Song]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), name: String, description: String = "", songs: [Song] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.songs = songs
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var songCount: Int { songs.count }
    var coverImageUrl: String? { songs.first?.imageUrl }
}
