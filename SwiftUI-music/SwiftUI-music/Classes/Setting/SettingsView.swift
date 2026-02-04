//
//  SettingsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  设置视图 - 集成 AuthService 和 StorageManager
//

import SwiftUI

struct SettingsView: View {
    // 认证服务
    @StateObject private var authService = AuthService.shared
    // 存储管理器
    @StateObject private var storageManager = StorageManager.shared
    
    // 显示登录页
    @State private var showLogin: Bool = false
    // 显示退出确认
    @State private var showLogoutConfirm: Bool = false
    
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
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)
                
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
                SettingsSectionView(title: "账号") {
                    VStack(spacing: 0) {
                        SettingsItemView.withChevron(
                            iconName: "person.circle",
                            iconBackgroundColor: .purple,
                            iconForegroundColor: .purple,
                            title: "个人资料",
                            action: {}
                        )
                        Divider()
                        SettingsItemView.withChevron(
                            iconName: "envelope",
                            iconBackgroundColor: .green,
                            iconForegroundColor: .green,
                            title: "邮箱与安全",
                            action: {}
                        )
                        Divider()
                        SettingsItemView.withChevron(
                            iconName: "bell",
                            iconBackgroundColor: .blue,
                            iconForegroundColor: .blue,
                            title: "通知设置",
                            action: {}
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 播放设置 - 绑定 StorageManager
                SettingsSectionView(title: "播放") {
                    VStack(spacing: 0) {
                        SettingsItemView.withText(
                            iconName: "slider.horizontal.3",
                            iconBackgroundColor: .red,
                            iconForegroundColor: .red,
                            title: "音频质量",
                            text: storageManager.audioQuality.rawValue
                        )
                        Divider()
                        SettingsItemView.withChevron(
                            iconName: "waveform",
                            iconBackgroundColor: .yellow,
                            iconForegroundColor: .yellow,
                            title: "均衡器",
                            action: {}
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
                
                // 下载设置 - 绑定 StorageManager
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
                
                // 存储管理
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
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 关于与支持
                SettingsSectionView(title: "关于与支持") {
                    VStack(spacing: 0) {
                        SettingsItemView.withChevron(
                            iconName: "info.circle",
                            iconBackgroundColor: .gray,
                            iconForegroundColor: .gray,
                            title: "关于我们",
                            action: {}
                        )
                        Divider()
                        SettingsItemView.withChevron(
                            iconName: "questionmark.circle",
                            iconBackgroundColor: .gray,
                            iconForegroundColor: .gray,
                            title: "帮助与反馈",
                            action: {}
                        )
                        Divider()
                        SettingsItemView.withChevron(
                            iconName: "shield",
                            iconBackgroundColor: .gray,
                            iconForegroundColor: .gray,
                            title: "隐私政策",
                            action: {}
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 登录/退出登录按钮
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
                
                // 版本信息
                Text("版本 v1.0.1 (202207)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showLogin) {
            LoginView()
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
}

#Preview {
    SettingsView()
}
