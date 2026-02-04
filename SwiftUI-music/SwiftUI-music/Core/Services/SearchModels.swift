//
//  SearchModels.swift
//  SwiftUI-music
//
//  搜索服务模型定义
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 搜索类型
/// 搜索结果类型
enum SearchType: String, CaseIterable, Sendable {
    case all = "全部"
    case songs = "歌曲"
    case artists = "艺术家"
    case albums = "专辑"
    case playlists = "歌单"
}

// MARK: - 本地搜索结果
/// 本地搜索结果
struct LocalSearchResults: Sendable {
    var songs: [Song]
    var artists: [ArtistInfo]
    var albums: [AlbumInfo]
    var playlists: [PlaylistInfo]
    
    var isEmpty: Bool {
        songs.isEmpty && artists.isEmpty && albums.isEmpty && playlists.isEmpty
    }
    
    var totalCount: Int {
        songs.count + artists.count + albums.count + playlists.count
    }
    
    static let empty = LocalSearchResults(songs: [], artists: [], albums: [], playlists: [])
}

// MARK: - 搜索结果项视图模型
/// 搜索结果项类型
enum SearchResultItem: Identifiable, Sendable {
    case song(Song)
    case artist(ArtistInfo)
    case album(AlbumInfo)
    case playlist(PlaylistInfo)
    
    var id: UUID {
        switch self {
        case .song(let song): return song.id
        case .artist(let artist): return artist.id
        case .album(let album): return album.id
        case .playlist(let playlist): return playlist.id
        }
    }
    
    var title: String {
        switch self {
        case .song(let song): return song.title
        case .artist(let artist): return artist.name
        case .album(let album): return album.name
        case .playlist(let playlist): return playlist.name
        }
    }
    
    var subtitle: String {
        switch self {
        case .song(let song): return song.artist
        case .artist(let artist): return "\(artist.followers ?? 0) 粉丝"
        case .album(let album): return album.artist
        case .playlist(let playlist): return "\(playlist.songCount) 首歌"
        }
    }
    
    var imageUrl: String {
        switch self {
        case .song(let song): return song.imageUrl
        case .artist(let artist): return artist.imageUrl
        case .album(let album): return album.imageUrl
        case .playlist(let playlist): return playlist.imageUrl
        }
    }
    
    var type: SearchType {
        switch self {
        case .song: return .songs
        case .artist: return .artists
        case .album: return .albums
        case .playlist: return .playlists
        }
    }
}
