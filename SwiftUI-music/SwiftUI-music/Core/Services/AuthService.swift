//
//  AuthService.swift
//  SwiftUI-music
//
//  用户认证服务 - 管理登录/注册/退出等功能
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation
import Combine

// MARK: - 认证服务
/// 用户认证服务 - 单例模式
@MainActor
final class AuthService: ObservableObject {
    
    // MARK: - 单例
    static let shared = AuthService()
    
    // MARK: - Published 属性
    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var currentUser: User?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - 计算属性
    var isLoggedIn: Bool {
        authState == .loggedIn && currentUser != nil
    }
    
    // MARK: - 初始化
    private init() {
        checkAuthState()
    }
    
    // MARK: - 认证状态检查
    
    func checkAuthState() {
        isLoading = true
        let isLoggedIn = defaults.bool(forKey: StorageKey.isLoggedIn.rawValue)
        
        if isLoggedIn {
            if let userData = defaults.data(forKey: StorageKey.currentUser.rawValue),
               let user = try? decoder.decode(User.self, from: userData) {
                self.currentUser = user
                self.authState = .loggedIn
            } else {
                logout()
            }
        } else {
            authState = .loggedOut
        }
        
        isLoading = false
    }
    
    // MARK: - 登录
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
        
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
        
        saveUser(user)
        let token = UUID().uuidString
        defaults.set(token, forKey: StorageKey.userToken.rawValue)
        currentUser = user
        authState = .loggedIn
    }
    
    func loginWithPhone(phone: String, code: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard phone.count >= 11 else { throw AuthError.invalidCredentials }
        guard code.count == 6 else { throw AuthError.invalidCredentials }
        
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
    
    func register(username: String, email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard !username.isEmpty else { throw AuthError.usernameAlreadyExists }
        guard email.contains("@") else { throw AuthError.invalidCredentials }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        
        try await Task.sleep(nanoseconds: 800_000_000)
        
        let user = User(
            username: username,
            email: email,
            avatarUrl: nil,
            favorites: 0,
            playlists: 0,
            following: 0,
            followers: 0
        )
        
        saveUser(user)
        currentUser = user
        authState = .loggedIn
    }
    
    // MARK: - 退出登录
    
    func logout() {
        defaults.removeObject(forKey: StorageKey.currentUser.rawValue)
        defaults.removeObject(forKey: StorageKey.userToken.rawValue)
        defaults.set(false, forKey: StorageKey.isLoggedIn.rawValue)
        currentUser = nil
        authState = .loggedOut
    }
    
    // MARK: - 用户信息更新
    
    func updateUser(_ user: User) {
        saveUser(user)
        currentUser = user
    }
    
    func updateAvatar(url: String) {
        guard var user = currentUser else { return }
        user.avatarUrl = url
        updateUser(user)
    }
    
    func updateUsername(_ username: String) throws {
        guard !username.isEmpty else { throw AuthError.usernameAlreadyExists }
        guard var user = currentUser else { return }
        user.username = username
        updateUser(user)
    }
    
    // MARK: - 密码管理
    
    func sendPasswordResetEmail(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard email.contains("@") else { throw AuthError.invalidCredentials }
        try await Task.sleep(nanoseconds: 500_000_000)
        print("✉️ 密码重置邮件已发送至: \(email)")
    }
    
    func changePassword(oldPassword: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard newPassword.count >= 6 else { throw AuthError.weakPassword }
        try await Task.sleep(nanoseconds: 500_000_000)
        print("🔐 密码修改成功")
    }
    
    // MARK: - 验证码
    
    func sendVerificationCode(phone: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard phone.count >= 11 else { throw AuthError.invalidCredentials }
        try await Task.sleep(nanoseconds: 500_000_000)
        print("📱 验证码已发送至: \(phone)")
    }
    
    // MARK: - 私有方法
    
    private func saveUser(_ user: User) {
        if let userData = try? encoder.encode(user) {
            defaults.set(userData, forKey: StorageKey.currentUser.rawValue)
            defaults.set(true, forKey: StorageKey.isLoggedIn.rawValue)
        }
    }
}
