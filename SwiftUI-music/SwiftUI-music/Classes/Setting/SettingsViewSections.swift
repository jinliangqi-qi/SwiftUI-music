//
//  SettingsViewSections.swift
//  SwiftUI-music
//
//  设置视图各区块组件
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 设置视图区块扩展
extension SettingsView {
    
    var accountSection: some View {
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
    
    var playbackSection: some View {
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
                    isOn: Binding(
                        get: { StorageManager.shared.autoPlayEnabled },
                        set: { StorageManager.shared.autoPlayEnabled = $0 }
                    )
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    var downloadSection: some View {
        SettingsSectionView(title: "下载") {
            VStack(spacing: 0) {
                SettingsItemView.withText(
                    iconName: "arrow.down.circle",
                    iconBackgroundColor: .indigo,
                    iconForegroundColor: .indigo,
                    title: "下载质量",
                    text: StorageManager.shared.downloadQuality.rawValue
                )
                Divider()
                SettingsItemView.withToggle(
                    iconName: "wifi",
                    iconBackgroundColor: .teal,
                    iconForegroundColor: .teal,
                    title: "仅WiFi下载",
                    isOn: Binding(
                        get: { StorageManager.shared.wifiOnlyDownload },
                        set: { StorageManager.shared.wifiOnlyDownload = $0 }
                    )
                )
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    var storageSection: some View {
        SettingsSectionView(title: "存储") {
            VStack(spacing: 0) {
                SettingsItemView.withText(
                    iconName: "internaldrive",
                    iconBackgroundColor: .orange,
                    iconForegroundColor: .orange,
                    title: "已下载",
                    text: "\(StorageManager.shared.downloadedSongs.count) 首"
                )
                Divider()
                SettingsItemView.withText(
                    iconName: "heart.fill",
                    iconBackgroundColor: .red,
                    iconForegroundColor: .red,
                    title: "收藏歌曲",
                    text: "\(StorageManager.shared.likedSongs.count) 首"
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
    
    var aboutSection: some View {
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
    
    var loginButton: some View {
        Button(action: {
            if AuthService.shared.isLoggedIn {
                showLogoutConfirm = true
            } else {
                showLogin = true
            }
        }) {
            Text(AuthService.shared.isLoggedIn ? "退出登录" : "登录账号")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AuthService.shared.isLoggedIn ? .red : .purple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    var versionInfo: some View {
        Text("版本 v1.0.1 (202207)")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .padding(.top, 16)
            .padding(.bottom, isWideLayout ? 140 : 100)
    }
}
