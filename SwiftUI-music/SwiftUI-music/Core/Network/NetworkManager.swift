//
//  NetworkManager.swift
//  SwiftUI-music
//
//  网络层管理器 - 封装音乐 API 请求，支持数据缓存
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 网络管理器
/// 网络请求管理器 - 支持数据缓存
actor NetworkManager {
    
    // MARK: - 单例
    static let shared = NetworkManager()
    
    // MARK: - 私有属性
    private let session: URLSession
    private let decoder: JSONDecoder
    private var baseURL: String = "https://api.example.com/v1"
    private let timeout: TimeInterval = 30
    private var cacheEnabled: Bool = true
    
    // MARK: - 初始化
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - 配置
    func setBaseURL(_ url: String) { self.baseURL = url }
    func setCacheEnabled(_ enabled: Bool) { self.cacheEnabled = enabled }
    
    // MARK: - 缓存辅助方法
    private func getFromCache<T: Decodable & Sendable>(_ type: T.Type, cacheKey: APICacheKey) async -> T? {
        guard cacheEnabled else { return nil }
        return await MainActor.run { CacheManager.shared.getData(type, forKey: cacheKey.key) }
    }
    
    private func saveToCache<T: Encodable & Sendable>(_ value: T, cacheKey: APICacheKey) async {
        guard cacheEnabled else { return }
        await MainActor.run { CacheManager.shared.setData(value, forKey: cacheKey.key) }
    }
    
    // MARK: - 搜索 API
    
    func search(query: String, type: String = "all", limit: Int = 20, useCache: Bool = true) async throws -> SearchResults {
        let cacheKey = APICacheKey.search(query: query)
        
        if useCache, let cached: SearchResults = await getFromCache(SearchResults.self, cacheKey: cacheKey) {
            print("📦 使用缓存: 搜索结果 - \(query)")
            return cached
        }
        
        let results = generateMockSearchResults(query: query)
        await saveToCache(results, cacheKey: cacheKey)
        print("💾 已缓存: 搜索结果 - \(query)")
        return results
    }
    
    func getHotSearches(useCache: Bool = true) async throws -> [String] {
        let cacheKey = APICacheKey.hotSearches
        
        if useCache, let cached: [String] = await getFromCache([String].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 热门搜索")
            return cached
        }
        
        let results = ["周杰伦", "陈奕迅", "林俊杰", "Taylor Swift", "华语流行", "热门说唱", "抖音热歌", "独立民谣", "粤语经典"]
        await saveToCache(results, cacheKey: cacheKey)
        return results
    }
    
    // MARK: - 歌曲 API
    
    func getSongDetail(songId: String, useCache: Bool = true) async throws -> Song {
        let cacheKey = APICacheKey.songDetail(id: songId)
        
        if useCache, let cached: Song = await getFromCache(Song.self, cacheKey: cacheKey) {
            print("📦 使用缓存: 歌曲详情 - \(songId)")
            return cached
        }
        
        let song = MusicData.recentlyPlayed.first!
        await saveToCache(song, cacheKey: cacheKey)
        return song
    }
    
    func getSongPlayUrl(songId: String) async throws -> String {
        return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    }
    
    func getLyrics(songId: String) async throws -> String {
        return """
        [00:00.00] 作词 : 方文山
        [00:01.00] 作曲 : 周杰伦
        [00:02.00]
        [00:15.00] 你听见 风声了吗
        [00:20.00] 风声吹动树叶飘动就像我的心
        [00:25.00] 动着摇着
        [00:30.00] 一步两步三步四步望着天
        """
    }
    
    // MARK: - 推荐 API
    
    func getRecommendedSongs(limit: Int = 20, useCache: Bool = true) async throws -> [Song] {
        let cacheKey = APICacheKey.recommendedSongs
        
        if useCache, let cached: [Song] = await getFromCache([Song].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 推荐歌曲")
            return cached
        }
        
        let songs = MusicData.recentlyPlayed
        await saveToCache(songs, cacheKey: cacheKey)
        return songs
    }
    
    func getRecommendedPlaylists(limit: Int = 10, useCache: Bool = true) async throws -> [Playlist] {
        let cacheKey = APICacheKey.recommendedPlaylists
        
        if useCache, let cached: [Playlist] = await getFromCache([Playlist].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 推荐歌单")
            return cached
        }
        
        let playlists = MusicData.playlists
        await saveToCache(playlists, cacheKey: cacheKey)
        return playlists
    }
    
    func getRecommendedArtists(limit: Int = 10, useCache: Bool = true) async throws -> [ArtistInfo] {
        let cacheKey = APICacheKey.recommendedArtists
        
        if useCache, let cached: [ArtistInfo] = await getFromCache([ArtistInfo].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 推荐艺术家")
            return cached
        }
        
        let artists = generateMockArtists()
        await saveToCache(artists, cacheKey: cacheKey)
        return artists
    }
    
    // MARK: - 歌单 API
    
    func getPlaylistDetail(playlistId: String) async throws -> (PlaylistInfo, [Song]) {
        let playlist = PlaylistInfo(
            name: "热门歌单",
            creator: "官方",
            imageUrl: MusicData.playlists.first?.imageUrl ?? "",
            songCount: MusicData.recentlyPlayed.count
        )
        return (playlist, MusicData.recentlyPlayed)
    }
    
    // MARK: - 排行榜 API
    
    func getCharts(useCache: Bool = true) async throws -> [PlaylistInfo] {
        let cacheKey = APICacheKey.charts
        
        if useCache, let cached: [PlaylistInfo] = await getFromCache([PlaylistInfo].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 排行榜")
            return cached
        }
        
        let charts = [
            PlaylistInfo(name: "飙升榜", creator: "官方", imageUrl: MusicData.playlists[0].imageUrl, songCount: 100),
            PlaylistInfo(name: "新歌榜", creator: "官方", imageUrl: MusicData.playlists[1].imageUrl, songCount: 100),
            PlaylistInfo(name: "热歌榜", creator: "官方", imageUrl: MusicData.playlists[2].imageUrl, songCount: 100),
            PlaylistInfo(name: "原创榜", creator: "官方", imageUrl: MusicData.playlists[3].imageUrl, songCount: 100)
        ]
        
        await saveToCache(charts, cacheKey: cacheKey)
        return charts
    }
    
    // MARK: - 强制刷新方法
    
    func refreshSearch(query: String) async throws -> SearchResults {
        return try await search(query: query, useCache: false)
    }
    
    func refreshRecommendedSongs() async throws -> [Song] {
        return try await getRecommendedSongs(useCache: false)
    }
    
    func refreshRecommendedPlaylists() async throws -> [Playlist] {
        return try await getRecommendedPlaylists(useCache: false)
    }
}
