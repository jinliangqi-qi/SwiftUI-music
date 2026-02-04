//
//  SearchService.swift
//  SwiftUI-music
//
//  搜索服务 - 提供搜索逻辑和结果过滤
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import Combine

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

// MARK: - 搜索服务
/// 搜索服务 - 提供本地和远程搜索功能
@MainActor
final class SearchService: ObservableObject {
    
    // MARK: - 单例
    static let shared = SearchService()
    
    // MARK: - Published 属性
    /// 搜索结果
    @Published private(set) var searchResults: LocalSearchResults = .empty
    
    /// 是否正在搜索
    @Published private(set) var isSearching: Bool = false
    
    /// 搜索类型
    @Published var searchType: SearchType = .all
    
    /// 热门搜索关键词
    @Published private(set) var hotSearches: [String] = []
    
    // MARK: - 私有属性
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - 初始化
    private init() {
        loadHotSearches()
    }
    
    // MARK: - 搜索方法
    
    /// 执行搜索
    /// - Parameter query: 搜索关键词
    func search(query: String) {
        // 取消之前的搜索任务
        searchTask?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 空查询时清空结果
        guard !trimmedQuery.isEmpty else {
            searchResults = .empty
            isSearching = false
            return
        }
        
        isSearching = true
        
        // 创建新的搜索任务（带防抖）
        searchTask = Task {
            // 防抖延迟
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            
            // 检查是否被取消
            guard !Task.isCancelled else { return }
            
            // 执行本地搜索
            let results = await performLocalSearch(query: trimmedQuery)
            
            // 更新结果
            guard !Task.isCancelled else { return }
            searchResults = results
            isSearching = false
            
            // 保存搜索历史
            StorageManager.shared.addSearchHistory(trimmedQuery)
        }
    }
    
    /// 执行本地搜索
    private func performLocalSearch(query: String) async -> LocalSearchResults {
        let lowercasedQuery = query.lowercased()
        
        // 搜索歌曲
        let songs: [Song]
        if searchType == .all || searchType == .songs {
            songs = MusicData.allSongs.filter { song in
                song.title.lowercased().contains(lowercasedQuery) ||
                song.artist.lowercased().contains(lowercasedQuery) ||
                (song.album?.lowercased().contains(lowercasedQuery) ?? false) ||
                (song.genre?.lowercased().contains(lowercasedQuery) ?? false)
            }
        } else {
            songs = []
        }
        
        // 搜索艺术家
        let artists: [ArtistInfo]
        if searchType == .all || searchType == .artists {
            artists = getLocalArtists().filter { artist in
                artist.name.lowercased().contains(lowercasedQuery)
            }
        } else {
            artists = []
        }
        
        // 搜索专辑
        let albums: [AlbumInfo]
        if searchType == .all || searchType == .albums {
            albums = getLocalAlbums().filter { album in
                album.name.lowercased().contains(lowercasedQuery) ||
                album.artist.lowercased().contains(lowercasedQuery)
            }
        } else {
            albums = []
        }
        
        // 搜索歌单
        let playlists: [PlaylistInfo]
        if searchType == .all || searchType == .playlists {
            playlists = MusicData.playlists.map { playlist in
                PlaylistInfo(
                    name: playlist.title,
                    creator: "官方",
                    imageUrl: playlist.imageUrl,
                    songCount: playlist.songCount
                )
            }.filter { playlist in
                playlist.name.lowercased().contains(lowercasedQuery)
            }
        } else {
            playlists = []
        }
        
        return LocalSearchResults(
            songs: songs,
            artists: artists,
            albums: albums,
            playlists: playlists
        )
    }
    
    /// 清空搜索结果
    func clearResults() {
        searchTask?.cancel()
        searchResults = .empty
        isSearching = false
    }
    
    // MARK: - 热门搜索
    
    /// 加载热门搜索
    private func loadHotSearches() {
        Task {
            do {
                hotSearches = try await NetworkManager.shared.getHotSearches()
            } catch {
                // 使用默认热门搜索
                hotSearches = [
                    "周杰伦", "陈奕迅", "林俊杰", "Taylor Swift",
                    "华语流行", "热门说唱", "抖音热歌", "独立民谣"
                ]
            }
        }
    }
    
    /// 刷新热门搜索
    func refreshHotSearches() {
        loadHotSearches()
    }
    
    // MARK: - 本地数据源
    
    /// 获取本地艺术家列表
    private func getLocalArtists() -> [ArtistInfo] {
        // 从歌曲中提取艺术家
        var artistSet = Set<String>()
        var artists: [ArtistInfo] = []
        
        for song in MusicData.allSongs {
            if !artistSet.contains(song.artist) {
                artistSet.insert(song.artist)
                artists.append(ArtistInfo(
                    name: song.artist,
                    imageUrl: song.imageUrl,
                    followers: Int.random(in: 10000...1000000),
                    genres: [song.genre ?? "流行"]
                ))
            }
        }
        
        return artists
    }
    
    /// 获取本地专辑列表
    private func getLocalAlbums() -> [AlbumInfo] {
        // 从歌曲中提取专辑
        var albumSet = Set<String>()
        var albums: [AlbumInfo] = []
        
        for song in MusicData.allSongs {
            if let album = song.album, !albumSet.contains(album) {
                albumSet.insert(album)
                albums.append(AlbumInfo(
                    name: album,
                    artist: song.artist,
                    imageUrl: song.imageUrl,
                    releaseDate: song.releaseDate,
                    songCount: Int.random(in: 8...15)
                ))
            }
        }
        
        return albums
    }
    
    // MARK: - 搜索建议
    
    /// 获取搜索建议
    /// - Parameter query: 输入的关键词
    /// - Returns: 建议列表
    func getSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercasedQuery = query.lowercased()
        var suggestions: [String] = []
        
        // 从热门搜索中获取建议
        suggestions.append(contentsOf: hotSearches.filter {
            $0.lowercased().contains(lowercasedQuery)
        })
        
        // 从搜索历史中获取建议
        suggestions.append(contentsOf: StorageManager.shared.searchHistory.filter {
            $0.lowercased().contains(lowercasedQuery) && !suggestions.contains($0)
        })
        
        // 从歌曲标题中获取建议
        for song in MusicData.allSongs {
            if song.title.lowercased().contains(lowercasedQuery) && !suggestions.contains(song.title) {
                suggestions.append(song.title)
            }
            if song.artist.lowercased().contains(lowercasedQuery) && !suggestions.contains(song.artist) {
                suggestions.append(song.artist)
            }
        }
        
        return Array(suggestions.prefix(10))
    }
    
    /// 添加搜索历史
    /// - Parameter query: 搜索关键词
    func addToSearchHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        StorageManager.shared.addSearchHistory(trimmed)
    }
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
