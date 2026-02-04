//
//  NetworkModels.swift
//  SwiftUI-music
//
//  网络层模型定义
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation

// MARK: - API 错误类型
/// 网络请求错误枚举
enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case noData
    case unauthorized
    case rateLimited
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .noData:
            return "没有数据"
        case .unauthorized:
            return "未授权访问"
        case .rateLimited:
            return "请求过于频繁"
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - API 响应包装
/// 通用 API 响应结构
struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}

// MARK: - 搜索结果模型
/// 搜索结果
struct SearchResults: Codable, Sendable {
    let songs: [Song]
    let artists: [ArtistInfo]
    let albums: [AlbumInfo]
    let playlists: [PlaylistInfo]
}

/// 艺术家信息
struct ArtistInfo: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let imageUrl: String
    let followers: Int?
    let genres: [String]?
    
    init(id: UUID = UUID(), name: String, imageUrl: String, followers: Int? = nil, genres: [String]? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.followers = followers
        self.genres = genres
    }
}

/// 专辑信息
struct AlbumInfo: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let artist: String
    let imageUrl: String
    let releaseDate: String?
    let songCount: Int?
    
    init(id: UUID = UUID(), name: String, artist: String, imageUrl: String, releaseDate: String? = nil, songCount: Int? = nil) {
        self.id = id
        self.name = name
        self.artist = artist
        self.imageUrl = imageUrl
        self.releaseDate = releaseDate
        self.songCount = songCount
    }
}

/// 歌单信息
struct PlaylistInfo: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let creator: String
    let imageUrl: String
    let songCount: Int
    let playCount: Int?
    
    init(id: UUID = UUID(), name: String, creator: String, imageUrl: String, songCount: Int, playCount: Int? = nil) {
        self.id = id
        self.name = name
        self.creator = creator
        self.imageUrl = imageUrl
        self.songCount = songCount
        self.playCount = playCount
    }
}

// MARK: - 缓存键生成
/// API 缓存键
enum APICacheKey {
    case search(query: String)
    case hotSearches
    case recommendedSongs
    case recommendedPlaylists
    case recommendedArtists
    case songDetail(id: String)
    case playlistDetail(id: String)
    case charts
    
    var key: String {
        switch self {
        case .search(let query):
            return "api_search_\(query)"
        case .hotSearches:
            return "api_hot_searches"
        case .recommendedSongs:
            return "api_recommended_songs"
        case .recommendedPlaylists:
            return "api_recommended_playlists"
        case .recommendedArtists:
            return "api_recommended_artists"
        case .songDetail(let id):
            return "api_song_\(id)"
        case .playlistDetail(let id):
            return "api_playlist_\(id)"
        case .charts:
            return "api_charts"
        }
    }
}
