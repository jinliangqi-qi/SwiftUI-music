//
//  CacheManagerOperations.swift
//  SwiftUI-music
//
//  缓存管理器扩展 - 缓存清理和统计操作
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation
import UIKit

// MARK: - 缓存清理扩展
extension CacheManager {
    
    // MARK: - 缓存清理
    
    func clearMemoryCache() {
        imageMemoryCache.removeAllObjects()
        dataMemoryCache.removeAllObjects()
        print("🧹 内存缓存已清除")
    }
    
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
    
    func clearAllCache() async {
        clearMemoryCache()
        for type in CacheType.allCases {
            await clearDiskCache(for: type)
        }
    }
    
    func clearExpiredCache() async {
        for type in CacheType.allCases {
            let directoryURL = cacheDirectoryURL(for: type)
            
            guard let contents = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil) else {
                continue
            }
            
            for fileURL in contents {
                if fileURL.lastPathComponent.hasSuffix("_metadata") { continue }
                
                let key = fileURL.lastPathComponent
                if let metadata = getMetadata(for: key, type: type), metadata.isExpired {
                    await removeFromDisk(key: key, type: type)
                }
            }
        }
        
        await calculateCacheSize()
    }
    
    func removeFromDisk(key: String, type: CacheType) async {
        let fileURL = cacheFileURL(for: key, type: type)
        let metadataURL = cacheFileURL(for: key + "_metadata", type: type)
        
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: metadataURL)
    }
    
    // MARK: - 缓存统计
    
    func calculateCacheSize() async {
        var imageSize: Int64 = 0
        var dataSize: Int64 = 0
        var audioSize: Int64 = 0
        
        for type in CacheType.allCases {
            let directoryURL = cacheDirectoryURL(for: type)
            let size = calculateDirectorySize(at: directoryURL)
            
            switch type {
            case .image: imageSize = size
            case .data: dataSize = size
            case .audio: audioSize = size
            }
        }
        
        await MainActor.run {
            self.imageCacheSize = imageSize
            self.dataCacheSize = dataSize
            self.audioCacheSize = audioSize
            self.totalCacheSize = imageSize + dataSize + audioSize
        }
    }
    
    func calculateDirectorySize(at url: URL) -> Int64 {
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
    
    func formattedSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
