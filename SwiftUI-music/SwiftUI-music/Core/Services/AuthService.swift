//
//  AuthService.swift
//  SwiftUI-music
//
//  用户认证服务 - 管理登录/注册/退出等功能
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import Combine

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

// MARK: - 认证服务
/// 用户认证服务 - 单例模式
@MainActor
final class AuthService: ObservableObject {
    
    // MARK: - 单例
    static let shared = AuthService()
    
    // MARK: - Published 属性
    /// 当前认证状态
    @Published private(set) var authState: AuthState = .unknown
    
    /// 当前登录用户
    @Published private(set) var currentUser: User?
    
    /// 是否正在加载
    @Published private(set) var isLoading: Bool = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - 计算属性
    /// 是否已登录
    var isLoggedIn: Bool {
        authState == .loggedIn && currentUser != nil
    }
    
    // MARK: - 初始化
    private init() {
        checkAuthState()
    }
    
    // MARK: - 认证状态检查
    
    /// 检查当前认证状态
    func checkAuthState() {
        isLoading = true
        
        // 检查是否有保存的登录状态
        let isLoggedIn = defaults.bool(forKey: StorageKey.isLoggedIn.rawValue)
        
        if isLoggedIn {
            // 尝试加载用户信息
            if let userData = defaults.data(forKey: StorageKey.currentUser.rawValue),
               let user = try? decoder.decode(User.self, from: userData) {
                self.currentUser = user
                self.authState = .loggedIn
            } else {
                // 数据损坏，清除登录状态
                logout()
            }
        } else {
            authState = .loggedOut
        }
        
        isLoading = false
    }
    
    // MARK: - 登录
    
    /// 使用邮箱和密码登录
    /// - Parameters:
    ///   - email: 邮箱
    ///   - password: 密码
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // 验证输入
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        
        // 模拟登录验证（实际应调用后端 API）
        // 演示用：任何有效格式的邮箱都可登录
        guard email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        // 创建用户（模拟后端返回）
        let user = User(
            username: email.components(separatedBy: "@").first ?? "用户",
            email: email,
            avatarUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500",
            bio: "这是一个音乐爱好者",
            favorites: 428,
            playlists: 32,
            following: 286,
            followers: 142
        )
        
        // 保存登录状态
        saveUser(user)
        
        // 生成并保存 Token（模拟）
        let token = UUID().uuidString
        defaults.set(token, forKey: StorageKey.userToken.rawValue)
        
        // 更新状态
        currentUser = user
        authState = .loggedIn
    }
    
    /// 使用手机号登录（验证码）
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    func loginWithPhone(phone: String, code: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // 模拟验证
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard phone.count >= 11 else {
            throw AuthError.invalidCredentials
        }
        
        guard code.count == 6 else {
            throw AuthError.invalidCredentials
        }
        
        // 创建用户
        let user = User(
            username: "用户\(phone.suffix(4))",
            email: "\(phone)@phone.local",
            avatarUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500",
            favorites: 0,
            playlists: 0,
            following: 0,
            followers: 0
        )
        
        saveUser(user)
        currentUser = user
        authState = .loggedIn
    }
    
    // MARK: - 注册
    
    /// 注册新用户
    /// - Parameters:
    ///   - username: 用户名
    ///   - email: 邮箱
    ///   - password: 密码
    func register(username: String, email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        // 验证输入
        guard !username.isEmpty else {
            throw AuthError.usernameAlreadyExists
        }
        
        guard email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // 创建新用户
        let user = User(
            username: username,
            email: email,
            avatarUrl: nil,
            favorites: 0,
            playlists: 0,
            following: 0,
            followers: 0
        )
        
        // 保存用户
        saveUser(user)
        
        // 更新状态
        currentUser = user
        authState = .loggedIn
    }
    
    // MARK: - 退出登录
    
    /// 退出登录
    func logout() {
        // 清除用户数据
        defaults.removeObject(forKey: StorageKey.currentUser.rawValue)
        defaults.removeObject(forKey: StorageKey.userToken.rawValue)
        defaults.set(false, forKey: StorageKey.isLoggedIn.rawValue)
        
        // 更新状态
        currentUser = nil
        authState = .loggedOut
    }
    
    // MARK: - 用户信息更新
    
    /// 更新用户资料
    /// - Parameter user: 更新后的用户信息
    func updateUser(_ user: User) {
        saveUser(user)
        currentUser = user
    }
    
    /// 更新头像
    /// - Parameter url: 头像 URL
    func updateAvatar(url: String) {
        guard var user = currentUser else { return }
        user.avatarUrl = url
        updateUser(user)
    }
    
    /// 更新用户名
    /// - Parameter username: 新用户名
    func updateUsername(_ username: String) throws {
        guard !username.isEmpty else {
            throw AuthError.usernameAlreadyExists
        }
        
        guard var user = currentUser else { return }
        user.username = username
        updateUser(user)
    }
    
    // MARK: - 密码管理
    
    /// 发送密码重置邮件
    /// - Parameter email: 邮箱地址
    func sendPasswordResetEmail(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        // 模拟发送
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 实际应调用后端 API
        print("✉️ 密码重置邮件已发送至: \(email)")
    }
    
    /// 修改密码
    /// - Parameters:
    ///   - oldPassword: 旧密码
    ///   - newPassword: 新密码
    func changePassword(oldPassword: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard newPassword.count >= 6 else {
            throw AuthError.weakPassword
        }
        
        // 模拟验证
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 实际应调用后端 API
        print("🔐 密码修改成功")
    }
    
    // MARK: - 验证码
    
    /// 发送验证码
    /// - Parameter phone: 手机号
    func sendVerificationCode(phone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard phone.count >= 11 else {
            throw AuthError.invalidCredentials
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 实际应调用后端 API
        print("📱 验证码已发送至: \(phone)")
    }
    
    // MARK: - 私有方法
    
    /// 保存用户信息
    private func saveUser(_ user: User) {
        if let userData = try? encoder.encode(user) {
            defaults.set(userData, forKey: StorageKey.currentUser.rawValue)
            defaults.set(true, forKey: StorageKey.isLoggedIn.rawValue)
        }
    }
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
