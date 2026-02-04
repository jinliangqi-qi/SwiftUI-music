//
//  SearchService.swift
//  SwiftUI-music
//
//  搜索服务 - 提供搜索逻辑和结果过滤
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import Combine

// MARK: - 搜索服务
/// 搜索服务 - 提供本地和远程搜索功能
@MainActor
final class SearchService: ObservableObject {
    
    // MARK: - 单例
    static let shared = SearchService()
    
    // MARK: - Published 属性
    @Published private(set) var searchResults: LocalSearchResults = .empty
    @Published private(set) var isSearching: Bool = false
    @Published var searchType: SearchType = .all
    @Published private(set) var hotSearches: [String] = []
    
    // MARK: - 私有属性
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.3
    
    // MARK: - 初始化
    private init() {
        loadHotSearches()
    }
    
    // MARK: - 搜索方法
    
    func search(query: String) {
        searchTask?.cancel()
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            searchResults = .empty
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            
            let results = await performLocalSearch(query: trimmedQuery)
            guard !Task.isCancelled else { return }
            
            searchResults = results
            isSearching = false
            StorageManager.shared.addSearchHistory(trimmedQuery)
        }
    }
    
    private func performLocalSearch(query: String) async -> LocalSearchResults {
        let lowercasedQuery = query.lowercased()
        
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
        
        let artists: [ArtistInfo]
        if searchType == .all || searchType == .artists {
            artists = getLocalArtists().filter { $0.name.lowercased().contains(lowercasedQuery) }
        } else {
            artists = []
        }
        
        let albums: [AlbumInfo]
        if searchType == .all || searchType == .albums {
            albums = getLocalAlbums().filter {
                $0.name.lowercased().contains(lowercasedQuery) ||
                $0.artist.lowercased().contains(lowercasedQuery)
            }
        } else {
            albums = []
        }
        
        let playlists: [PlaylistInfo]
        if searchType == .all || searchType == .playlists {
            playlists = MusicData.playlists.map { playlist in
                PlaylistInfo(name: playlist.title, creator: "官方", imageUrl: playlist.imageUrl, songCount: playlist.songCount)
            }.filter { $0.name.lowercased().contains(lowercasedQuery) }
        } else {
            playlists = []
        }
        
        return LocalSearchResults(songs: songs, artists: artists, albums: albums, playlists: playlists)
    }
    
    func clearResults() {
        searchTask?.cancel()
        searchResults = .empty
        isSearching = false
    }
    
    // MARK: - 热门搜索
    
    private func loadHotSearches() {
        Task {
            do {
                hotSearches = try await NetworkManager.shared.getHotSearches()
            } catch {
                hotSearches = ["周杰伦", "陈奕迅", "林俊杰", "Taylor Swift", "华语流行", "热门说唱", "抖音热歌", "独立民谣"]
            }
        }
    }
    
    func refreshHotSearches() { loadHotSearches() }
    
    // MARK: - 本地数据源
    
    private func getLocalArtists() -> [ArtistInfo] {
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
    
    private func getLocalAlbums() -> [AlbumInfo] {
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
    
    func getSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercasedQuery = query.lowercased()
        var suggestions: [String] = []
        
        suggestions.append(contentsOf: hotSearches.filter { $0.lowercased().contains(lowercasedQuery) })
        suggestions.append(contentsOf: StorageManager.shared.searchHistory.filter {
            $0.lowercased().contains(lowercasedQuery) && !suggestions.contains($0)
        })
        
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
    
    func addToSearchHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        StorageManager.shared.addSearchHistory(trimmed)
    }
}
