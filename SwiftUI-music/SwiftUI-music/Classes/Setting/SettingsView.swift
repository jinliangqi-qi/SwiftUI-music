//
//  SettingsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  设置视图 - 集成 AuthService 和 StorageManager，支持 iPhone/iPad 响应式布局
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.isWideLayout) private var isWideLayout
    
    // 认证服务
    @StateObject private var authService = AuthService.shared
    // 存储管理器
    @StateObject private var storageManager = StorageManager.shared
    
    // 显示登录页
    @State private var showLogin: Bool = false
    // 显示退出确认
    @State private var showLogoutConfirm: Bool = false
    
    // 页面导航状态
    @State private var showProfileEdit = false
    @State private var showEmailSecurity = false
    @State private var showNotifications = false
    @State private var showAudioQuality = false
    @State private var showEqualizer = false
    @State private var showAbout = false
    @State private var showHelpFeedback = false
    @State private var showPrivacyPolicy = false
    @State private var showCacheSettings = false
    
    // 用户信息
    private var userName: String {
        authService.currentUser?.username ?? "未登录"
    }
    
    private var userHandle: String {
        if let user = authService.currentUser {
            return "@\(user.email.components(separatedBy: "@").first ?? "user")"
        }
        return "点击登录账号"
    }
    
    private var avatarUrl: String {
        authService.currentUser?.avatarUrl ?? "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 标题
                HStack {
                    Text("设置")
                        .font(.system(size: isWideLayout ? 34 : 28, weight: .bold))
                        .padding(.horizontal, isWideLayout ? 32 : 16)
                    Spacer()
                }
                .padding(.top)
                
                // 宽屏使用两列布局
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
        .sheet(isPresented: $showLogin) {
            LoginView()
        }
        .sheet(isPresented: $showProfileEdit) {
            ProfileEditView()
        }
        .sheet(isPresented: $showEmailSecurity) {
            EmailSecurityView()
        }
        .sheet(isPresented: $showNotifications) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showAudioQuality) {
            AudioQualitySettingsView()
        }
        .sheet(isPresented: $showEqualizer) {
            EqualizerView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showHelpFeedback) {
            HelpFeedbackView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showCacheSettings) {
            CacheSettingsView()
        }
        .alert("确认退出", isPresented: $showLogoutConfirm) {
            Button("取消", role: .cancel) {}
            Button("退出", role: .destructive) {
                authService.logout()
            }
        } message: {
            Text("确定要退出登录吗？")
        }
    }
    
    // MARK: - 紧凑布局（iPhone 和 iPad 竖屏）
    private var compactSettingsLayout: some View {
        VStack(spacing: 0) {
            // 用户信息卡片
            UserProfileCardView(
                userName: userName,
                userHandle: userHandle,
                avatarUrl: avatarUrl,
                action: {
                    if !authService.isLoggedIn {
                        showLogin = true
                    }
                }
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 账号设置
            accountSection
            
            // 播放设置
            playbackSection
            
            // 下载设置
            downloadSection
            
            // 存储管理
            storageSection
            
            // 关于与支持
            aboutSection
            
            // 登录/退出登录按钮
            loginButton
            
            // 版本信息
            versionInfo
        }
    }
    
    // MARK: - 宽屏布局（iPad 横屏，两列）
    private var wideSettingsLayout: some View {
        VStack(spacing: 0) {
            // 用户信息卡片
            UserProfileCardView(
                userName: userName,
                userHandle: userHandle,
                avatarUrl: avatarUrl,
                action: {
                    if !authService.isLoggedIn {
                        showLogin = true
                    }
                }
            )
            .padding(.horizontal, 32)
            .padding(.top, 8)
            
            // 两列设置项
            HStack(alignment: .top, spacing: 24) {
                // 左列
                VStack(spacing: 0) {
                    accountSection
                    playbackSection
                    downloadSection
                }
                .frame(maxWidth: .infinity)
                
                // 右列
                VStack(spacing: 0) {
                    storageSection
                    aboutSection
                    loginButton
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            
            // 版本信息
            versionInfo
        }
    }
    
    // MARK: - 各设置区块
    private var accountSection: some View {
        SettingsSectionView(title: "账号") {
            VStack(spacing: 0) {
                SettingsItemView.withChevron(
                    iconName: "person.circle",
                    iconBackgroundColor: .purple,
                    iconForegroundColor: .purple,
                    title: "个人资料",
                    action: { showProfileEdit = true }
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "envelope",
                    iconBackgroundColor: .green,
                    iconForegroundColor: .green,
                    title: "邮箱与安全",
                    action: { showEmailSecurity = true }
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "bell",
                    iconBackgroundColor: .blue,
                    iconForegroundColor: .blue,
                    title: "通知设置",
                    action: { showNotifications = true }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var playbackSection: some View {
        SettingsSectionView(title: "播放") {
            VStack(spacing: 0) {
                SettingsItemView.withChevron(
                    iconName: "slider.horizontal.3",
                    iconBackgroundColor: .red,
                    iconForegroundColor: .red,
                    title: "音频质量",
                    action: { showAudioQuality = true }
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "waveform",
                    iconBackgroundColor: .yellow,
                    iconForegroundColor: .yellow,
                    title: "均衡器",
                    action: { showEqualizer = true }
                )
                Divider()
                SettingsItemView.withToggle(
                    iconName: "shuffle",
                    iconBackgroundColor: .pink,
                    iconForegroundColor: .pink,
                    title: "自动播放",
                    isOn: $storageManager.autoPlayEnabled
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var downloadSection: some View {
        SettingsSectionView(title: "下载") {
            VStack(spacing: 0) {
                SettingsItemView.withText(
                    iconName: "arrow.down.circle",
                    iconBackgroundColor: .indigo,
                    iconForegroundColor: .indigo,
                    title: "下载质量",
                    text: storageManager.downloadQuality.rawValue
                )
                Divider()
                SettingsItemView.withToggle(
                    iconName: "wifi",
                    iconBackgroundColor: .teal,
                    iconForegroundColor: .teal,
                    title: "仅WiFi下载",
                    isOn: $storageManager.wifiOnlyDownload
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var storageSection: some View {
        SettingsSectionView(title: "存储") {
            VStack(spacing: 0) {
                SettingsItemView.withText(
                    iconName: "internaldrive",
                    iconBackgroundColor: .orange,
                    iconForegroundColor: .orange,
                    title: "已下载",
                    text: "\(storageManager.downloadedSongs.count) 首"
                )
                Divider()
                SettingsItemView.withText(
                    iconName: "heart.fill",
                    iconBackgroundColor: .red,
                    iconForegroundColor: .red,
                    title: "收藏歌曲",
                    text: "\(storageManager.likedSongs.count) 首"
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "externaldrive.badge.xmark",
                    iconBackgroundColor: .purple,
                    iconForegroundColor: .purple,
                    title: "缓存管理",
                    action: { showCacheSettings = true }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var aboutSection: some View {
        SettingsSectionView(title: "关于与支持") {
            VStack(spacing: 0) {
                SettingsItemView.withChevron(
                    iconName: "info.circle",
                    iconBackgroundColor: .gray,
                    iconForegroundColor: .gray,
                    title: "关于我们",
                    action: { showAbout = true }
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "questionmark.circle",
                    iconBackgroundColor: .gray,
                    iconForegroundColor: .gray,
                    title: "帮助与反馈",
                    action: { showHelpFeedback = true }
                )
                Divider()
                SettingsItemView.withChevron(
                    iconName: "shield",
                    iconBackgroundColor: .gray,
                    iconForegroundColor: .gray,
                    title: "隐私政策",
                    action: { showPrivacyPolicy = true }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var loginButton: some View {
        Button(action: {
            if authService.isLoggedIn {
                showLogoutConfirm = true
            } else {
                showLogin = true
            }
        }) {
            Text(authService.isLoggedIn ? "退出登录" : "登录账号")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(authService.isLoggedIn ? .red : .purple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var versionInfo: some View {
        Text("版本 v1.0.1 (202207)")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.top, 16)
            .padding(.bottom, isWideLayout ? 140 : 100)
    }
}

#Preview {
    SettingsView()
}
