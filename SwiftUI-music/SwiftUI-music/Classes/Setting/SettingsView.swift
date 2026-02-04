//
//  SettingsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SettingsView: View {
    // 状态变量
    @State private var autoPlayEnabled = false
    @State private var wifiOnlyDownload = true
    
    // 用户信息
    private let userName = "小明"
    private let userHandle = "@xiaoming"
    private let avatarUrl = "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"
    
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
                        // 处理用户资料点击
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
                
                // 播放设置
                SettingsSectionView(title: "播放") {
                    VStack(spacing: 0) {
                        SettingsItemView.withText(
                            iconName: "slider.horizontal.3",
                            iconBackgroundColor: .red,
                            iconForegroundColor: .red,
                            title: "音频质量",
                            text: "高清"
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
                            isOn: $autoPlayEnabled
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 下载设置
                SettingsSectionView(title: "下载") {
                    VStack(spacing: 0) {
                        SettingsItemView.withText(
                            iconName: "arrow.down.circle",
                            iconBackgroundColor: .indigo,
                            iconForegroundColor: .indigo,
                            title: "下载质量",
                            text: "标准"
                        )
                        Divider()
                        SettingsItemView.withToggle(
                            iconName: "wifi",
                            iconBackgroundColor: .teal,
                            iconForegroundColor: .teal,
                            title: "仅WiFi下载",
                            isOn: $wifiOnlyDownload
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
                
                // 退出登录按钮
                Button(action: {
                    // 处理退出登录
                }) {
                    Text("退出登录")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
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
                    .padding(.bottom, 100) // 增加底部间距，为迷你播放器和导航栏留出空间
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SettingsView()
}
