//
//  AuthModels.swift
//  SwiftUI-music
//
//  用户认证模型定义
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 用户模型
/// 用户信息
struct User: Identifiable, Codable, Sendable {
    let id: UUID
    var username: String
    var email: String
    var avatarUrl: String?
    var bio: String?
    var createdAt: Date
    
    // 统计数据
    var favorites: Int
    var playlists: Int
    var following: Int
    var followers: Int
    
    init(
        id: UUID = UUID(),
        username: String,
        email: String,
        avatarUrl: String? = nil,
        bio: String? = nil,
        createdAt: Date = Date(),
        favorites: Int = 0,
        playlists: Int = 0,
        following: Int = 0,
        followers: Int = 0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.createdAt = createdAt
        self.favorites = favorites
        self.playlists = playlists
        self.following = following
        self.followers = followers
    }
}

// MARK: - 认证错误
/// 认证错误类型
enum AuthError: Error, LocalizedError, Sendable {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case usernameAlreadyExists
    case weakPassword
    case networkError
    case tokenExpired
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "邮箱或密码错误"
        case .userNotFound:
            return "用户不存在"
        case .emailAlreadyExists:
            return "该邮箱已被注册"
        case .usernameAlreadyExists:
            return "该用户名已被使用"
        case .weakPassword:
            return "密码强度不够，至少需要6位字符"
        case .networkError:
            return "网络连接失败"
        case .tokenExpired:
            return "登录已过期，请重新登录"
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - 认证状态
/// 认证状态枚举
enum AuthState: Sendable {
    case unknown      // 未知状态
    case loggedOut    // 已退出
    case loggedIn     // 已登录
}

// MARK: - 演示用户
extension User {
    /// 创建演示用户
    static var demo: User {
        User(
            username: "小明",
            email: "xiaoming@example.com",
            avatarUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500",
            bio: "音乐让生活更美好 🎵",
            favorites: 428,
            playlists: 32,
            following: 286,
            followers: 142
        )
    }
}
