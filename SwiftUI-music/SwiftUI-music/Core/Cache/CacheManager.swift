//
//  CacheManager.swift
//  SwiftUI-music
//
//  缓存管理器 - 提供内存和磁盘双重缓存
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation
import UIKit

// MARK: - 缓存管理器
/// 缓存管理器 - 支持内存和磁盘双重缓存
@MainActor
final class CacheManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = CacheManager()
    
    // MARK: - Published 属性
    @Published var totalCacheSize: Int64 = 0
    @Published var imageCacheSize: Int64 = 0
    @Published var dataCacheSize: Int64 = 0
    @Published var audioCacheSize: Int64 = 0
    
    // MARK: - 内部属性（供扩展访问）
    let imageMemoryCache = NSCache<NSString, UIImage>()
    let dataMemoryCache = NSCache<NSString, NSData>()
    let cacheBaseURL: URL
    let fileManager = FileManager.default
    let cacheQueue = DispatchQueue(label: "com.swiftui-music.cache", qos: .utility)
    let maxMemoryCacheCount = 100
    let maxMemoryCacheSize = 50 * 1024 * 1024
    
    // MARK: - 初始化
    private init() {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheBaseURL = cachesDirectory.appendingPathComponent("SwiftUIMusicCache", isDirectory: true)
        
        imageMemoryCache.countLimit = maxMemoryCacheCount
        imageMemoryCache.totalCostLimit = maxMemoryCacheSize
        dataMemoryCache.countLimit = maxMemoryCacheCount
        dataMemoryCache.totalCostLimit = maxMemoryCacheSize
        
        createCacheDirectories()
        
        Task { await calculateCacheSize() }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.clearMemoryCache() }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 目录管理
    
    private func createCacheDirectories() {
        for type in CacheType.allCases {
            let directoryURL = cacheBaseURL.appendingPathComponent(type.directoryName, isDirectory: true)
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        }
    }
    
    func cacheDirectoryURL(for type: CacheType) -> URL {
        cacheBaseURL.appendingPathComponent(type.directoryName, isDirectory: true)
    }
    
    func cacheFileURL(for key: String, type: CacheType) -> URL {
        let hashedKey = key.sha256Hash
        return cacheDirectoryURL(for: type).appendingPathComponent(hashedKey)
    }
    
    // MARK: - 图片缓存
    
    func getImage(forKey key: String) -> UIImage? {
        if let image = imageMemoryCache.object(forKey: key as NSString) {
            return image
        }
        
        let fileURL = cacheFileURL(for: key, type: .image)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        if let metadata = getMetadata(for: key, type: .image), metadata.isExpired {
            Task { await removeFromDisk(key: key, type: .image) }
            return nil
        }
        
        imageMemoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        return image
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 0.8)?.count ?? 0
        imageMemoryCache.setObject(image, forKey: key as NSString, cost: cost)
        
        Task.detached(priority: .utility) { [weak self] in
            await self?.saveImageToDisk(image, forKey: key)
        }
    }
    
    private func saveImageToDisk(_ image: UIImage, forKey key: String) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheFileURL(for: key, type: .image)
        
        do {
            try data.write(to: fileURL)
            let metadata = CacheEntryMetadata(
                key: key,
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(CacheType.image.expirationInterval),
                size: Int64(data.count)
            )
            saveMetadata(metadata, for: key, type: .image)
            await calculateCacheSize()
        } catch {
            print("❌ 保存图片缓存失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 数据缓存
    
    func getData<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = dataMemoryCache.object(forKey: key as NSString) as? Data,
           let decoded = try? JSONDecoder().decode(type, from: data) {
            return decoded
        }
        
        let fileURL = cacheFileURL(for: key, type: .data)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        if let metadata = getMetadata(for: key, type: .data), metadata.isExpired {
            Task { await removeFromDisk(key: key, type: .data) }
            return nil
        }
        
        guard let decoded = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        
        dataMemoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        return decoded
    }
    
    func setData<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        
        dataMemoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        Task.detached(priority: .utility) { [weak self] in
            await self?.saveDataToDisk(data, forKey: key)
        }
    }
    
    private func saveDataToDisk(_ data: Data, forKey key: String) async {
        let fileURL = cacheFileURL(for: key, type: .data)
        
        do {
            try data.write(to: fileURL)
            let metadata = CacheEntryMetadata(
                key: key,
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(CacheType.data.expirationInterval),
                size: Int64(data.count)
            )
            saveMetadata(metadata, for: key, type: .data)
            await calculateCacheSize()
        } catch {
            print("❌ 保存数据缓存失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 元数据管理
    
    func getMetadata(for key: String, type: CacheType) -> CacheEntryMetadata? {
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        guard let data = try? Data(contentsOf: metadataURL) else { return nil }
        return try? JSONDecoder().decode(CacheEntryMetadata.self, from: data)
    }
    
    func saveMetadata(_ metadata: CacheEntryMetadata, for key: String, type: CacheType) {
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: metadataURL)
        }
    }
}
