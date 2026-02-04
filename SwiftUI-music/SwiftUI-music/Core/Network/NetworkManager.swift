//
//  NetworkManager.swift
//  SwiftUI-music
//
//  网络层管理器 - 封装音乐 API 请求，支持数据缓存
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

// MARK: - 网络管理器
/// 网络请求管理器 - 支持数据缓存
actor NetworkManager {
    
    // MARK: - 单例
    static let shared = NetworkManager()
    
    // MARK: - 私有属性
    private let session: URLSession
    private let decoder: JSONDecoder
    
    /// API 基础 URL（可配置）
    private var baseURL: String = "https://api.example.com/v1"
    
    /// 请求超时时间
    private let timeout: TimeInterval = 30
    
    /// 是否启用缓存
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
    
    /// 设置 API 基础 URL
    func setBaseURL(_ url: String) {
        self.baseURL = url
    }
    
    /// 设置是否启用缓存
    func setCacheEnabled(_ enabled: Bool) {
        self.cacheEnabled = enabled
    }
    
    // MARK: - 缓存辅助方法
    
    /// 从缓存获取数据
    private func getFromCache<T: Decodable & Sendable>(_ type: T.Type, cacheKey: APICacheKey) async -> T? {
        guard cacheEnabled else { return nil }
        return await MainActor.run {
            CacheManager.shared.getData(type, forKey: cacheKey.key)
        }
    }
    
    /// 保存数据到缓存
    private func saveToCache<T: Encodable & Sendable>(_ value: T, cacheKey: APICacheKey) async {
        guard cacheEnabled else { return }
        await MainActor.run {
            CacheManager.shared.setData(value, forKey: cacheKey.key)
        }
    }
    
    // MARK: - 搜索 API
    
    /// 搜索歌曲、艺术家、专辑
    /// - Parameters:
    ///   - query: 搜索关键词
    ///   - type: 搜索类型（可选：song, artist, album, playlist, all）
    ///   - limit: 返回数量限制
    ///   - useCache: 是否使用缓存
    /// - Returns: 搜索结果
    func search(query: String, type: String = "all", limit: Int = 20, useCache: Bool = true) async throws -> SearchResults {
        let cacheKey = APICacheKey.search(query: query)
        
        // 尝试从缓存获取
        if useCache, let cached: SearchResults = await getFromCache(SearchResults.self, cacheKey: cacheKey) {
            print("📦 使用缓存: 搜索结果 - \(query)")
            return cached
        }
        
        // 由于没有真实 API，返回模拟数据
        let results = generateMockSearchResults(query: query)
        
        // 保存到缓存
        await saveToCache(results, cacheKey: cacheKey)
        print("💾 已缓存: 搜索结果 - \(query)")
        
        return results
    }
    
    /// 获取热门搜索关键词
    func getHotSearches(useCache: Bool = true) async throws -> [String] {
        let cacheKey = APICacheKey.hotSearches
        
        if useCache, let cached: [String] = await getFromCache([String].self, cacheKey: cacheKey) {
            print("📦 使用缓存: 热门搜索")
            return cached
        }
        
        // 返回模拟数据
        let results = [
            "周杰伦", "陈奕迅", "林俊杰", "Taylor Swift",
            "华语流行", "热门说唱", "抖音热歌", "独立民谣", "粤语经典"
        ]
        
        await saveToCache(results, cacheKey: cacheKey)
        return results
    }
    
    // MARK: - 歌曲 API
    
    /// 获取歌曲详情
    /// - Parameter songId: 歌曲 ID
    /// - Returns: 歌曲详情
    func getSongDetail(songId: String, useCache: Bool = true) async throws -> Song {
        let cacheKey = APICacheKey.songDetail(id: songId)
        
        if useCache, let cached: Song = await getFromCache(Song.self, cacheKey: cacheKey) {
            print("📦 使用缓存: 歌曲详情 - \(songId)")
            return cached
        }
        
        // 返回模拟数据
        let song = MusicData.recentlyPlayed.first!
        await saveToCache(song, cacheKey: cacheKey)
        return song
    }
    
    /// 获取歌曲播放 URL
    /// - Parameter songId: 歌曲 ID
    /// - Returns: 播放 URL
    func getSongPlayUrl(songId: String) async throws -> String {
        // 返回示例音频 URL（使用公开的测试音频）
        return "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    }
    
    /// 获取歌词
    /// - Parameter songId: 歌曲 ID
    /// - Returns: 歌词文本
    func getLyrics(songId: String) async throws -> String {
        // 返回模拟歌词
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
    
    /// 获取推荐歌曲
    /// - Parameter limit: 数量限制
    /// - Returns: 推荐歌曲列表
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
    
    /// 获取推荐歌单
    /// - Parameter limit: 数量限制
    /// - Returns: 推荐歌单列表
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
    
    /// 获取推荐艺术家
    /// - Parameter limit: 数量限制
    /// - Returns: 推荐艺术家列表
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
    
    /// 获取歌单详情
    /// - Parameter playlistId: 歌单 ID
    /// - Returns: 歌单详情和歌曲列表
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
    
    /// 获取排行榜列表
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
    
    /// 强制刷新搜索结果（忽略缓存）
    func refreshSearch(query: String) async throws -> SearchResults {
        return try await search(query: query, useCache: false)
    }
    
    /// 强制刷新推荐歌曲（忽略缓存）
    func refreshRecommendedSongs() async throws -> [Song] {
        return try await getRecommendedSongs(useCache: false)
    }
    
    /// 强制刷新推荐歌单（忽略缓存）
    func refreshRecommendedPlaylists() async throws -> [Playlist] {
        return try await getRecommendedPlaylists(useCache: false)
    }
    
    // MARK: - 通用请求方法
    
    /// 发送 GET 请求
    private func get<T: Decodable>(_ endpoint: String, parameters: [String: String]? = nil) async throws -> T {
        var urlString = "\(baseURL)\(endpoint)"
        
        if let params = parameters {
            let queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
            var components = URLComponents(string: urlString)
            components?.queryItems = queryItems
            urlString = components?.url?.absoluteString ?? urlString
        }
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加认证 Token（如果有）
        if let token = await getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return try decoder.decode(T.self, from: data)
            case 401:
                throw APIError.unauthorized
            case 429:
                throw APIError.rateLimited
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// 发送 POST 请求
    private func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let urlString = "\(baseURL)\(endpoint)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        if let token = await getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    /// 获取认证 Token
    private func getAuthToken() async -> String? {
        await MainActor.run {
            UserDefaults.standard.string(forKey: StorageKey.userToken.rawValue)
        }
    }
    
    // MARK: - 模拟数据生成
    
    /// 生成模拟搜索结果
    private func generateMockSearchResults(query: String) -> SearchResults {
        // 根据搜索词过滤
        let filteredSongs = MusicData.recentlyPlayed.filter { song in
            song.title.localizedCaseInsensitiveContains(query) ||
            song.artist.localizedCaseInsensitiveContains(query)
        }
        
        // 如果没有匹配，返回所有歌曲作为建议
        let songs = filteredSongs.isEmpty ? MusicData.recentlyPlayed : filteredSongs
        
        let artists = generateMockArtists().filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
        
        let albums = [
            AlbumInfo(name: "十一月的萧邦", artist: "周杰伦", imageUrl: MusicData.recentlyPlayed[0].imageUrl, releaseDate: "2005", songCount: 12),
            AlbumInfo(name: "U87", artist: "陈奕迅", imageUrl: MusicData.recentlyPlayed[1].imageUrl, releaseDate: "2005", songCount: 10),
            AlbumInfo(name: "乐与怒", artist: "Beyond", imageUrl: MusicData.recentlyPlayed[2].imageUrl, releaseDate: "1993", songCount: 11)
        ].filter { $0.name.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query) }
        
        let playlists = MusicData.playlists.map {
            PlaylistInfo(name: $0.title, creator: "官方", imageUrl: $0.imageUrl, songCount: $0.songCount)
        }.filter { $0.name.localizedCaseInsensitiveContains(query) }
        
        return SearchResults(
            songs: songs,
            artists: artists.isEmpty ? generateMockArtists() : artists,
            albums: albums.isEmpty ? [
                AlbumInfo(name: "十一月的萧邦", artist: "周杰伦", imageUrl: MusicData.recentlyPlayed[0].imageUrl)
            ] : albums,
            playlists: playlists.isEmpty ? MusicData.playlists.map {
                PlaylistInfo(name: $0.title, creator: "官方", imageUrl: $0.imageUrl, songCount: $0.songCount)
            } : playlists
        )
    }
    
    /// 生成模拟艺术家数据
    private func generateMockArtists() -> [ArtistInfo] {
        return [
            ArtistInfo(name: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500", followers: 10000000, genres: ["流行", "R&B"]),
            ArtistInfo(name: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500", followers: 8000000, genres: ["流行", "粤语"]),
            ArtistInfo(name: "林俊杰", imageUrl: "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=500", followers: 7500000, genres: ["流行", "R&B"]),
            ArtistInfo(name: "Taylor Swift", imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500", followers: 50000000, genres: ["Pop", "Country"])
        ]
    }
}

// MARK: - 便捷扩展
extension NetworkManager {
    
    /// 快速搜索歌曲
    func searchSongs(query: String) async throws -> [Song] {
        let results = try await search(query: query, type: "song")
        return results.songs
    }
    
    /// 快速搜索艺术家
    func searchArtists(query: String) async throws -> [ArtistInfo] {
        let results = try await search(query: query, type: "artist")
        return results.artists
    }
}
