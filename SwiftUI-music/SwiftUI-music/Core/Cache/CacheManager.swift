//
//  CacheManager.swift
//  SwiftUI-music
//
//  缓存管理器 - 提供内存和磁盘双重缓存
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation
import UIKit

// MARK: - 缓存类型枚举
/// 缓存类型
enum CacheType: String, CaseIterable {
    case image = "images"      // 图片缓存
    case data = "data"         // 数据缓存（API响应等）
    case audio = "audio"       // 音频缓存
    
    /// 缓存目录名称
    var directoryName: String { rawValue }
    
    /// 缓存过期时间（秒）
    var expirationInterval: TimeInterval {
        switch self {
        case .image: return 7 * 24 * 60 * 60  // 7天
        case .data: return 24 * 60 * 60       // 1天
        case .audio: return 30 * 24 * 60 * 60 // 30天
        }
    }
}

// MARK: - 缓存条目元数据
/// 缓存条目的元数据
struct CacheEntryMetadata: Codable {
    let key: String
    let createdAt: Date
    let expiresAt: Date
    let size: Int64
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - 缓存管理器
/// 缓存管理器 - 支持内存和磁盘双重缓存
@MainActor
final class CacheManager: ObservableObject {
    
    // MARK: - 单例
    static let shared = CacheManager()
    
    // MARK: - Published 属性
    /// 总缓存大小（字节）
    @Published private(set) var totalCacheSize: Int64 = 0
    
    /// 图片缓存大小
    @Published private(set) var imageCacheSize: Int64 = 0
    
    /// 数据缓存大小
    @Published private(set) var dataCacheSize: Int64 = 0
    
    /// 音频缓存大小
    @Published private(set) var audioCacheSize: Int64 = 0
    
    // MARK: - 私有属性
    /// 内存缓存 - 图片
    private let imageMemoryCache = NSCache<NSString, UIImage>()
    
    /// 内存缓存 - 数据
    private let dataMemoryCache = NSCache<NSString, NSData>()
    
    /// 缓存根目录
    private let cacheBaseURL: URL
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    /// 同步队列
    private let cacheQueue = DispatchQueue(label: "com.swiftui-music.cache", qos: .utility)
    
    /// 最大内存缓存数量
    private let maxMemoryCacheCount = 100
    
    /// 最大内存缓存大小（50MB）
    private let maxMemoryCacheSize = 50 * 1024 * 1024
    
    // MARK: - 初始化
    private init() {
        // 设置缓存根目录
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheBaseURL = cachesDirectory.appendingPathComponent("SwiftUIMusicCache", isDirectory: true)
        
        // 配置内存缓存
        imageMemoryCache.countLimit = maxMemoryCacheCount
        imageMemoryCache.totalCostLimit = maxMemoryCacheSize
        dataMemoryCache.countLimit = maxMemoryCacheCount
        dataMemoryCache.totalCostLimit = maxMemoryCacheSize
        
        // 创建缓存目录
        createCacheDirectories()
        
        // 计算缓存大小
        Task {
            await calculateCacheSize()
        }
        
        // 监听内存警告
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.clearMemoryCache()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 目录管理
    
    /// 创建缓存目录
    private func createCacheDirectories() {
        for type in CacheType.allCases {
            let directoryURL = cacheBaseURL.appendingPathComponent(type.directoryName, isDirectory: true)
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        }
    }
    
    /// 获取缓存目录URL
    private func cacheDirectoryURL(for type: CacheType) -> URL {
        cacheBaseURL.appendingPathComponent(type.directoryName, isDirectory: true)
    }
    
    /// 生成缓存文件路径
    private func cacheFileURL(for key: String, type: CacheType) -> URL {
        let hashedKey = key.sha256Hash
        return cacheDirectoryURL(for: type).appendingPathComponent(hashedKey)
    }
    
    // MARK: - 图片缓存
    
    /// 获取缓存的图片
    /// - Parameter key: 缓存键（通常是URL）
    /// - Returns: 缓存的图片，如果不存在则返回nil
    func getImage(forKey key: String) -> UIImage? {
        // 1. 先检查内存缓存
        if let image = imageMemoryCache.object(forKey: key as NSString) {
            return image
        }
        
        // 2. 检查磁盘缓存
        let fileURL = cacheFileURL(for: key, type: .image)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // 3. 检查是否过期
        if let metadata = getMetadata(for: key, type: .image), metadata.isExpired {
            // 过期则删除
            Task {
                await removeFromDisk(key: key, type: .image)
            }
            return nil
        }
        
        // 4. 将磁盘缓存加载到内存
        imageMemoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        
        return image
    }
    
    /// 缓存图片
    /// - Parameters:
    ///   - image: 要缓存的图片
    ///   - key: 缓存键
    func setImage(_ image: UIImage, forKey key: String) {
        // 1. 存入内存缓存
        let cost = image.jpegData(compressionQuality: 0.8)?.count ?? 0
        imageMemoryCache.setObject(image, forKey: key as NSString, cost: cost)
        
        // 2. 异步存入磁盘缓存
        Task.detached(priority: .utility) { [weak self] in
            await self?.saveImageToDisk(image, forKey: key)
        }
    }
    
    /// 将图片保存到磁盘
    private func saveImageToDisk(_ image: UIImage, forKey key: String) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheFileURL(for: key, type: .image)
        
        do {
            try data.write(to: fileURL)
            
            // 保存元数据
            let metadata = CacheEntryMetadata(
                key: key,
                createdAt: Date(),
                expiresAt: Date().addingTimeInterval(CacheType.image.expirationInterval),
                size: Int64(data.count)
            )
            saveMetadata(metadata, for: key, type: .image)
            
            // 更新缓存大小
            await calculateCacheSize()
        } catch {
            print("❌ 保存图片缓存失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 数据缓存
    
    /// 获取缓存的数据
    /// - Parameters:
    ///   - key: 缓存键
    ///   - type: 数据类型
    /// - Returns: 解码后的数据
    func getData<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        // 1. 先检查内存缓存
        if let data = dataMemoryCache.object(forKey: key as NSString) as? Data,
           let decoded = try? JSONDecoder().decode(type, from: data) {
            return decoded
        }
        
        // 2. 检查磁盘缓存
        let fileURL = cacheFileURL(for: key, type: .data)
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        // 3. 检查是否过期
        if let metadata = getMetadata(for: key, type: .data), metadata.isExpired {
            Task {
                await removeFromDisk(key: key, type: .data)
            }
            return nil
        }
        
        // 4. 解码并存入内存缓存
        guard let decoded = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        
        dataMemoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        return decoded
    }
    
    /// 缓存数据
    /// - Parameters:
    ///   - value: 要缓存的数据
    ///   - key: 缓存键
    func setData<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        
        // 1. 存入内存缓存
        dataMemoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
        
        // 2. 异步存入磁盘缓存
        Task.detached(priority: .utility) { [weak self] in
            await self?.saveDataToDisk(data, forKey: key)
        }
    }
    
    /// 将数据保存到磁盘
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
    
    /// 获取缓存元数据
    private func getMetadata(for key: String, type: CacheType) -> CacheEntryMetadata? {
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        guard let data = try? Data(contentsOf: metadataURL) else { return nil }
        return try? JSONDecoder().decode(CacheEntryMetadata.self, from: data)
    }
    
    /// 保存缓存元数据
    private func saveMetadata(_ metadata: CacheEntryMetadata, for key: String, type: CacheType) {
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        if let data = try? JSONEncoder().encode(metadata) {
            try? data.write(to: metadataURL)
        }
    }
    
    // MARK: - 缓存清理
    
    /// 清除内存缓存
    func clearMemoryCache() {
        imageMemoryCache.removeAllObjects()
        dataMemoryCache.removeAllObjects()
        print("🧹 内存缓存已清除")
    }
    
    /// 清除指定类型的磁盘缓存
    func clearDiskCache(for type: CacheType) async {
        let directoryURL = cacheDirectoryURL(for: type)
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
            print("🧹 \(type.rawValue) 磁盘缓存已清除")
        } catch {
            print("❌ 清除磁盘缓存失败: \(error.localizedDescription)")
        }
        
        await calculateCacheSize()
    }
    
    /// 清除所有缓存
    func clearAllCache() async {
        // 清除内存缓存
        clearMemoryCache()
        
        // 清除所有类型的磁盘缓存
        for type in CacheType.allCases {
            await clearDiskCache(for: type)
        }
    }
    
    /// 清除过期缓存
    func clearExpiredCache() async {
        for type in CacheType.allCases {
            let directoryURL = cacheDirectoryURL(for: type)
            
            guard let contents = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
                continue
            }
            
            for fileURL in contents {
                // 跳过元数据文件
                if fileURL.lastPathComponent.hasSuffix("_metadata") {
                    continue
                }
                
                let key = fileURL.lastPathComponent
                if let metadata = getMetadata(for: key, type: type), metadata.isExpired {
                    await removeFromDisk(key: key, type: type)
                }
            }
        }
        
        await calculateCacheSize()
    }
    
    /// 从磁盘删除缓存
    private func removeFromDisk(key: String, type: CacheType) async {
        let fileURL = cacheFileURL(for: key, type: type)
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: metadataURL)
    }
    
    // MARK: - 缓存统计
    
    /// 计算缓存大小
    func calculateCacheSize() async {
        var imageSize: Int64 = 0
        var dataSize: Int64 = 0
        var audioSize: Int64 = 0
        
        for type in CacheType.allCases {
            let directoryURL = cacheDirectoryURL(for: type)
            let size = calculateDirectorySize(at: directoryURL)
            
            switch type {
            case .image:
                imageSize = size
            case .data:
                dataSize = size
            case .audio:
                audioSize = size
            }
        }
        
        await MainActor.run {
            self.imageCacheSize = imageSize
            self.dataCacheSize = dataSize
            self.audioCacheSize = audioSize
            self.totalCacheSize = imageSize + dataSize + audioSize
        }
    }
    
    /// 计算目录大小
    private func calculateDirectorySize(at url: URL) -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for fileURL in contents {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        return totalSize
    }
    
    /// 格式化缓存大小显示
    func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - String 哈希扩展
extension String {
    /// 生成 SHA256 哈希值
    var sha256Hash: String {
        guard let data = self.data(using: .utf8) else { return self }
        
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - CommonCrypto 导入
import CommonCrypto
