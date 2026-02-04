//
//  NetworkManagerHelpers.swift
//  SwiftUI-music
//
//  网络层辅助方法 - 通用请求和模拟数据
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 网络管理器扩展 - 通用请求方法
extension NetworkManager {
    
    /// 发送 GET 请求
    func get<T: Decodable>(_ endpoint: String, parameters: [String: String]? = nil) async throws -> T {
        var urlString = "https://api.example.com/v1\(endpoint)"
        
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
        
        if let token = await getAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
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
    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let urlString = "https://api.example.com/v1\(endpoint)"
        
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
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.self, from: data)
    }
    
    /// 获取认证 Token
    func getAuthToken() async -> String? {
        await MainActor.run {
            UserDefaults.standard.string(forKey: StorageKey.userToken.rawValue)
        }
    }
    
    // MARK: - 模拟数据生成
    
    /// 生成模拟搜索结果
    func generateMockSearchResults(query: String) -> SearchResults {
        let filteredSongs = MusicData.recentlyPlayed.filter { song in
            song.title.localizedCaseInsensitiveContains(query) ||
            song.artist.localizedCaseInsensitiveContains(query)
        }
        
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
    func generateMockArtists() -> [ArtistInfo] {
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
