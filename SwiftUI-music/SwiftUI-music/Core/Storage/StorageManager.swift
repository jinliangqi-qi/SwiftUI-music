//
//  StorageManager.swift
//  SwiftUI-music
//
//  本地存储管理器 - 使用 UserDefaults 实现数据持久化
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 存储管理器
/// 本地存储管理器 - 单例模式
@MainActor
final class StorageManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = StorageManager()
    
    // MARK: - Published 属性
    @Published private(set) var likedSongs: [Song] = []
    @Published private(set) var recentlyPlayed: [Song] = []
    @Published private(set) var searchHistory: [String] = []
    @Published private(set) var downloadedSongs: [Song] = []
    @Published private(set) var userPlaylists: [UserPlaylist] = []
    
    // MARK: - 设置属性
    @Published var audioQuality: AudioQuality = .medium {
        didSet { save(audioQuality.rawValue, forKey: .audioQuality) }
    }
    
    @Published var downloadQuality: AudioQuality = .medium {
        didSet { save(downloadQuality.rawValue, forKey: .downloadQuality) }
    }
    
    @Published var autoPlayEnabled: Bool = false {
        didSet { save(autoPlayEnabled, forKey: .autoPlayEnabled) }
    }
    
    @Published var wifiOnlyDownload: Bool = true {
        didSet { save(wifiOnlyDownload, forKey: .wifiOnlyDownload) }
    }
    
    // MARK: - 私有属性
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let maxHistoryCount = 50
    private let maxSearchHistoryCount = 20
    
    // MARK: - 初始化
    private init() {
        loadAllData()
    }
    
    // MARK: - 数据加载
    private func loadAllData() {
        likedSongs = load([Song].self, forKey: .likedSongs) ?? []
        recentlyPlayed = load([Song].self, forKey: .recentlyPlayed) ?? []
        searchHistory = load([String].self, forKey: .searchHistory) ?? []
        downloadedSongs = load([Song].self, forKey: .downloadedSongs) ?? []
        userPlaylists = load([UserPlaylist].self, forKey: .playlists) ?? []
        
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
    
    func addLikedSong(_ song: Song) {
        guard !likedSongs.contains(where: { $0.id == song.id }) else { return }
        likedSongs.insert(song, at: 0)
        save(likedSongs, forKey: .likedSongs)
    }
    
    func removeLikedSong(_ song: Song) {
        likedSongs.removeAll { $0.id == song.id }
        save(likedSongs, forKey: .likedSongs)
    }
    
    func isSongLiked(_ song: Song) -> Bool {
        likedSongs.contains { $0.id == song.id }
    }
    
    func toggleLikedSong(_ song: Song) {
        if isSongLiked(song) {
            removeLikedSong(song)
        } else {
            addLikedSong(song)
        }
    }
    
    // MARK: - 最近播放管理
    
    func addToRecentlyPlayed(_ song: Song) {
        recentlyPlayed.removeAll { $0.id == song.id }
        recentlyPlayed.insert(song, at: 0)
        if recentlyPlayed.count > maxHistoryCount {
            recentlyPlayed = Array(recentlyPlayed.prefix(maxHistoryCount))
        }
        save(recentlyPlayed, forKey: .recentlyPlayed)
    }
    
    func clearRecentlyPlayed() {
        recentlyPlayed.removeAll()
        save(recentlyPlayed, forKey: .recentlyPlayed)
    }
    
    // MARK: - 搜索历史管理
    
    func addSearchHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        searchHistory.removeAll { $0 == trimmed }
        searchHistory.insert(trimmed, at: 0)
        if searchHistory.count > maxSearchHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxSearchHistoryCount))
        }
        save(searchHistory, forKey: .searchHistory)
    }
    
    func removeSearchHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        save(searchHistory, forKey: .searchHistory)
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        save(searchHistory, forKey: .searchHistory)
    }
    
    // MARK: - 已下载歌曲管理
    
    func addDownloadedSong(_ song: Song) {
        guard !downloadedSongs.contains(where: { $0.id == song.id }) else { return }
        downloadedSongs.insert(song, at: 0)
        save(downloadedSongs, forKey: .downloadedSongs)
    }
    
    func removeDownloadedSong(_ song: Song) {
        downloadedSongs.removeAll { $0.id == song.id }
        save(downloadedSongs, forKey: .downloadedSongs)
    }
    
    func isSongDownloaded(_ song: Song) -> Bool {
        downloadedSongs.contains { $0.id == song.id }
    }
    
    // MARK: - 歌单管理
    
    @discardableResult
    func createPlaylist(name: String, description: String = "") -> UserPlaylist {
        let playlist = UserPlaylist(name: name, description: description, songs: [])
        userPlaylists.insert(playlist, at: 0)
        save(userPlaylists, forKey: .playlists)
        return playlist
    }
    
    func deletePlaylist(_ playlist: UserPlaylist) {
        userPlaylists.removeAll { $0.id == playlist.id }
        save(userPlaylists, forKey: .playlists)
    }
    
    func addSongToPlaylist(_ song: Song, playlist: UserPlaylist) {
        guard let index = userPlaylists.firstIndex(where: { $0.id == playlist.id }) else { return }
        guard !userPlaylists[index].songs.contains(where: { $0.id == song.id }) else { return }
        userPlaylists[index].songs.append(song)
        save(userPlaylists, forKey: .playlists)
    }
    
    func removeSongFromPlaylist(_ song: Song, playlist: UserPlaylist) {
        guard let index = userPlaylists.firstIndex(where: { $0.id == playlist.id }) else { return }
        userPlaylists[index].songs.removeAll { $0.id == song.id }
        save(userPlaylists, forKey: .playlists)
    }
    
    // MARK: - 播放状态保存/恢复
    
    func savePlaybackState(song: Song?, position: Double, queue: [Song]) {
        if let song = song { save(song, forKey: .lastPlayedSong) }
        defaults.set(position, forKey: StorageKey.lastPlaybackPosition.rawValue)
        save(queue, forKey: .lastPlayQueue)
    }
    
    func restorePlaybackState() -> (Song?, Double, [Song]) {
        let song = load(Song.self, forKey: .lastPlayedSong)
        let position = defaults.double(forKey: StorageKey.lastPlaybackPosition.rawValue)
        let queue = load([Song].self, forKey: .lastPlayQueue) ?? []
        return (song, position, queue)
    }
    
    // MARK: - 通用存储方法
    
    private func save<T: Encodable>(_ value: T, forKey key: StorageKey) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            print("❌ 保存数据失败 [\(key.rawValue)]: \(error.localizedDescription)")
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ 加载数据失败 [\(key.rawValue)]: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func save(_ value: Any, forKey key: StorageKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func remove(forKey key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
    
    func clearAllData() {
        StorageKey.allCases.forEach { key in
            defaults.removeObject(forKey: key.rawValue)
        }
        loadAllData()
    }
}
