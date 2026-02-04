//
//  StorageManager.swift
//  SwiftUI-music
//
//  本地存储管理器 - 使用 UserDefaults 实现数据持久化
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

// MARK: - 可存储协议
/// 可编码为 JSON 的协议
protocol StorableModel: Codable, Sendable {}

// MARK: - 存储管理器
/// 本地存储管理器 - 单例模式
@MainActor
final class StorageManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = StorageManager()
    
    // MARK: - Published 属性
    /// 收藏的歌曲
    @Published private(set) var likedSongs: [Song] = []
    
    /// 最近播放
    @Published private(set) var recentlyPlayed: [Song] = []
    
    /// 搜索历史
    @Published private(set) var searchHistory: [String] = []
    
    /// 已下载歌曲
    @Published private(set) var downloadedSongs: [Song] = []
    
    /// 用户创建的歌单
    @Published private(set) var userPlaylists: [UserPlaylist] = []
    
    // MARK: - 设置属性
    /// 音频质量
    @Published var audioQuality: AudioQuality = .medium {
        didSet { save(audioQuality.rawValue, forKey: .audioQuality) }
    }
    
    /// 下载质量
    @Published var downloadQuality: AudioQuality = .medium {
        didSet { save(downloadQuality.rawValue, forKey: .downloadQuality) }
    }
    
    /// 自动播放
    @Published var autoPlayEnabled: Bool = false {
        didSet { save(autoPlayEnabled, forKey: .autoPlayEnabled) }
    }
    
    /// 仅 WiFi 下载
    @Published var wifiOnlyDownload: Bool = true {
        didSet { save(wifiOnlyDownload, forKey: .wifiOnlyDownload) }
    }
    
    // MARK: - 私有属性
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// 最大历史记录数量
    private let maxHistoryCount = 50
    
    /// 最大搜索历史数量
    private let maxSearchHistoryCount = 20
    
    // MARK: - 初始化
    private init() {
        loadAllData()
    }
    
    // MARK: - 数据加载
    /// 加载所有持久化数据
    private func loadAllData() {
        // 加载收藏歌曲
        likedSongs = load([Song].self, forKey: .likedSongs) ?? []
        
        // 加载最近播放
        recentlyPlayed = load([Song].self, forKey: .recentlyPlayed) ?? []
        
        // 加载搜索历史
        searchHistory = load([String].self, forKey: .searchHistory) ?? []
        
        // 加载已下载歌曲
        downloadedSongs = load([Song].self, forKey: .downloadedSongs) ?? []
        
        // 加载用户歌单
        userPlaylists = load([UserPlaylist].self, forKey: .playlists) ?? []
        
        // 加载设置
        if let quality = defaults.string(forKey: StorageKey.audioQuality.rawValue),
           let audioQuality = AudioQuality(rawValue: quality) {
            self.audioQuality = audioQuality
        }
        
        if let quality = defaults.string(forKey: StorageKey.downloadQuality.rawValue),
           let downloadQuality = AudioQuality(rawValue: quality) {
            self.downloadQuality = downloadQuality
        }
        
        autoPlayEnabled = defaults.bool(forKey: StorageKey.autoPlayEnabled.rawValue)
        wifiOnlyDownload = defaults.object(forKey: StorageKey.wifiOnlyDownload.rawValue) as? Bool ?? true
    }
    
    // MARK: - 收藏歌曲管理
    
    /// 添加收藏歌曲
    /// - Parameter song: 要收藏的歌曲
    func addLikedSong(_ song: Song) {
        guard !likedSongs.contains(where: { $0.id == song.id }) else { return }
        likedSongs.insert(song, at: 0)
        save(likedSongs, forKey: .likedSongs)
    }
    
    /// 移除收藏歌曲
    /// - Parameter song: 要移除的歌曲
    func removeLikedSong(_ song: Song) {
        likedSongs.removeAll { $0.id == song.id }
        save(likedSongs, forKey: .likedSongs)
    }
    
    /// 检查歌曲是否已收藏
    /// - Parameter song: 要检查的歌曲
    /// - Returns: 是否已收藏
    func isSongLiked(_ song: Song) -> Bool {
        likedSongs.contains { $0.id == song.id }
    }
    
    /// 切换收藏状态
    /// - Parameter song: 歌曲
    func toggleLikedSong(_ song: Song) {
        if isSongLiked(song) {
            removeLikedSong(song)
        } else {
            addLikedSong(song)
        }
    }
    
    // MARK: - 最近播放管理
    
    /// 添加到最近播放
    /// - Parameter song: 播放的歌曲
    func addToRecentlyPlayed(_ song: Song) {
        // 移除已存在的相同歌曲
        recentlyPlayed.removeAll { $0.id == song.id }
        // 插入到开头
        recentlyPlayed.insert(song, at: 0)
        // 限制数量
        if recentlyPlayed.count > maxHistoryCount {
            recentlyPlayed = Array(recentlyPlayed.prefix(maxHistoryCount))
        }
        save(recentlyPlayed, forKey: .recentlyPlayed)
    }
    
    /// 清空最近播放
    func clearRecentlyPlayed() {
        recentlyPlayed.removeAll()
        save(recentlyPlayed, forKey: .recentlyPlayed)
    }
    
    // MARK: - 搜索历史管理
    
    /// 添加搜索历史
    /// - Parameter query: 搜索关键词
    func addSearchHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 移除已存在的相同记录
        searchHistory.removeAll { $0 == trimmed }
        // 插入到开头
        searchHistory.insert(trimmed, at: 0)
        // 限制数量
        if searchHistory.count > maxSearchHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxSearchHistoryCount))
        }
        save(searchHistory, forKey: .searchHistory)
    }
    
    /// 移除搜索历史
    /// - Parameter query: 要移除的关键词
    func removeSearchHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        save(searchHistory, forKey: .searchHistory)
    }
    
    /// 清空搜索历史
    func clearSearchHistory() {
        searchHistory.removeAll()
        save(searchHistory, forKey: .searchHistory)
    }
    
    // MARK: - 已下载歌曲管理
    
    /// 添加已下载歌曲
    /// - Parameter song: 下载的歌曲
    func addDownloadedSong(_ song: Song) {
        guard !downloadedSongs.contains(where: { $0.id == song.id }) else { return }
        downloadedSongs.insert(song, at: 0)
        save(downloadedSongs, forKey: .downloadedSongs)
    }
    
    /// 移除已下载歌曲
    /// - Parameter song: 要移除的歌曲
    func removeDownloadedSong(_ song: Song) {
        downloadedSongs.removeAll { $0.id == song.id }
        save(downloadedSongs, forKey: .downloadedSongs)
    }
    
    /// 检查歌曲是否已下载
    /// - Parameter song: 要检查的歌曲
    /// - Returns: 是否已下载
    func isSongDownloaded(_ song: Song) -> Bool {
        downloadedSongs.contains { $0.id == song.id }
    }
    
    // MARK: - 歌单管理
    
    /// 创建歌单
    /// - Parameters:
    ///   - name: 歌单名称
    ///   - description: 歌单描述
    /// - Returns: 新创建的歌单
    @discardableResult
    func createPlaylist(name: String, description: String = "") -> UserPlaylist {
        let playlist = UserPlaylist(name: name, description: description, songs: [])
        userPlaylists.insert(playlist, at: 0)
        save(userPlaylists, forKey: .playlists)
        return playlist
    }
    
    /// 删除歌单
    /// - Parameter playlist: 要删除的歌单
    func deletePlaylist(_ playlist: UserPlaylist) {
        userPlaylists.removeAll { $0.id == playlist.id }
        save(userPlaylists, forKey: .playlists)
    }
    
    /// 添加歌曲到歌单
    /// - Parameters:
    ///   - song: 要添加的歌曲
    ///   - playlist: 目标歌单
    func addSongToPlaylist(_ song: Song, playlist: UserPlaylist) {
        guard let index = userPlaylists.firstIndex(where: { $0.id == playlist.id }) else { return }
        guard !userPlaylists[index].songs.contains(where: { $0.id == song.id }) else { return }
        userPlaylists[index].songs.append(song)
        save(userPlaylists, forKey: .playlists)
    }
    
    /// 从歌单移除歌曲
    /// - Parameters:
    ///   - song: 要移除的歌曲
    ///   - playlist: 目标歌单
    func removeSongFromPlaylist(_ song: Song, playlist: UserPlaylist) {
        guard let index = userPlaylists.firstIndex(where: { $0.id == playlist.id }) else { return }
        userPlaylists[index].songs.removeAll { $0.id == song.id }
        save(userPlaylists, forKey: .playlists)
    }
    
    // MARK: - 播放状态保存/恢复
    
    /// 保存播放状态
    /// - Parameters:
    ///   - song: 当前歌曲
    ///   - position: 播放位置
    ///   - queue: 播放队列
    func savePlaybackState(song: Song?, position: Double, queue: [Song]) {
        if let song = song {
            save(song, forKey: .lastPlayedSong)
        }
        defaults.set(position, forKey: StorageKey.lastPlaybackPosition.rawValue)
        save(queue, forKey: .lastPlayQueue)
    }
    
    /// 恢复播放状态
    /// - Returns: (歌曲, 播放位置, 播放队列)
    func restorePlaybackState() -> (Song?, Double, [Song]) {
        let song = load(Song.self, forKey: .lastPlayedSong)
        let position = defaults.double(forKey: StorageKey.lastPlaybackPosition.rawValue)
        let queue = load([Song].self, forKey: .lastPlayQueue) ?? []
        return (song, position, queue)
    }
    
    // MARK: - 通用存储方法
    
    /// 保存 Codable 对象
    private func save<T: Encodable>(_ value: T, forKey key: StorageKey) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            print("❌ 保存数据失败 [\(key.rawValue)]: \(error.localizedDescription)")
        }
    }
    
    /// 加载 Codable 对象
    private func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ 加载数据失败 [\(key.rawValue)]: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 保存简单值
    private func save(_ value: Any, forKey key: StorageKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    /// 删除数据
    func remove(forKey key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
    
    /// 清除所有数据
    func clearAllData() {
        StorageKey.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
        loadAllData()
    }
}

// MARK: - StorageKey 扩展
extension StorageKey: CaseIterable {
    /// 所有存储键的集合（使用 let 确保并发安全）
    static let allCases: [StorageKey] = [
        .isLoggedIn, .currentUser, .userToken,
        .likedSongs, .recentlyPlayed, .searchHistory, .playlists, .downloadedSongs,
        .audioQuality, .downloadQuality, .autoPlayEnabled, .wifiOnlyDownload, .repeatMode, .shuffleEnabled,
        .lastPlayedSong, .lastPlaybackPosition, .lastPlayQueue
    ]
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
    
    /// 歌曲数量
    var songCount: Int { songs.count }
    
    /// 封面图片 URL（使用第一首歌的封面）
    var coverImageUrl: String? { songs.first?.imageUrl }
}
