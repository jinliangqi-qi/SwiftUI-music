//
//  CacheTypes.swift
//  SwiftUI-music
//
//  缓存类型和元数据定义
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import Foundation

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

// MARK: - String 哈希扩展
import CommonCrypto

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
