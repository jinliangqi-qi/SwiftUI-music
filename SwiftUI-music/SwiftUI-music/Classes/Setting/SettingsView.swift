//
//  SettingsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  设置视图 - 集成 AuthService 和 StorageManager，支持 iPhone/iPad 响应式布局
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.isWideLayout) var isWideLayout
    @StateObject private var authService = AuthService.shared
    @StateObject private var storageManager = StorageManager.shared
    
    // 这些 @State 属性需要从扩展中访问，所以不能是 private
    @State var showLogin: Bool = false
    @State var showLogoutConfirm: Bool = false
    @State var showProfileEdit = false
    @State var showEmailSecurity = false
    @State var showNotifications = false
    @State var showAudioQuality = false
    @State var showEqualizer = false
    @State var showAbout = false
    @State var showHelpFeedback = false
    @State var showPrivacyPolicy = false
    @State var showCacheSettings = false
    
    var userName: String {
        authService.currentUser?.username ?? "未登录"
    }
    
    var userHandle: String {
        if let user = authService.currentUser {
            return "@\(user.email.components(separatedBy: "@").first ?? "user")"
        }
        return "点击登录账号"
    }
    
    var avatarUrl: String {
        authService.currentUser?.avatarUrl ?? "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("设置")
                        .font(.system(size: isWideLayout ? 34 : 28, weight: .bold))
                        .padding(.horizontal, isWideLayout ? 32 : 16)
                    Spacer()
                }
                .padding(.top)
                
                if isWideLayout {
                    wideSettingsLayout
                } else {
                    compactSettingsLayout
                }
            }
            .frame(maxWidth: isWideLayout ? 900 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showLogin) { LoginView() }
        .sheet(isPresented: $showProfileEdit) { ProfileEditView() }
        .sheet(isPresented: $showEmailSecurity) { EmailSecurityView() }
        .sheet(isPresented: $showNotifications) { NotificationSettingsView() }
        .sheet(isPresented: $showAudioQuality) { AudioQualitySettingsView() }
        .sheet(isPresented: $showEqualizer) { EqualizerView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showHelpFeedback) { HelpFeedbackView() }
        .sheet(isPresented: $showPrivacyPolicy) { PrivacyPolicyView() }
        .sheet(isPresented: $showCacheSettings) { CacheSettingsView() }
        .alert("确认退出", isPresented: $showLogoutConfirm) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) { authService.logout() }
        } message: {
            Text("确定要退出登录吗？")
        }
    }
    
    // MARK: - 紧凑布局
    private var compactSettingsLayout: some View {
        VStack(spacing: 0) {
            UserProfileCardView(
                userName: userName,
                userHandle: userHandle,
                avatarUrl: avatarUrl,
                action: { if !authService.isLoggedIn { showLogin = true } }
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            accountSection
            playbackSection
            downloadSection
            storageSection
            aboutSection
            loginButton
            versionInfo
        }
    }
    
    // MARK: - 宽屏布局
    private var wideSettingsLayout: some View {
        VStack(spacing: 0) {
            UserProfileCardView(
                userName: userName,
                userHandle: userHandle,
                avatarUrl: avatarUrl,
                action: { if !authService.isLoggedIn { showLogin = true } }
            )
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 0) {
                    accountSection
                    playbackSection
                    downloadSection
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 0) {
                    storageSection
                    aboutSection
                    loginButton
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            
            versionInfo
        }
    }
}

#Preview {
    SettingsView()
}
