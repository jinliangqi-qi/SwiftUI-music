//
//  NotificationSettingsView.swift
//  SwiftUI-music
//
//  通知设置页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI
import UserNotifications

// MARK: - 通知设置视图
struct NotificationSettingsView: View {
    // 通知设置状态
    @State private var pushEnabled = true
    @State private var newMusicEnabled = true
    @State private var playlistUpdateEnabled = true
    @State private var artistUpdateEnabled = false
    @State private var socialEnabled = true
    @State private var commentEnabled = true
    @State private var likeEnabled = true
    @State private var followEnabled = true
    @State private var systemEnabled = true
    @State private var promotionEnabled = false
    
    // 系统通知权限状态
    @State private var systemPermissionGranted = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        SettingsDetailContainer(title: "通知设置") {
            // 系统通知权限
            systemNotificationSection
            
            // 音乐通知
            SettingsGroupHeader(title: "音乐通知")
            
            SettingsCard {
                SettingsToggleRow(
                    title: "新歌推荐",
                    subtitle: "收到新歌发行通知",
                    isOn: $newMusicEnabled
                )
                
                Divider().padding(.leading, 16)
                
                SettingsToggleRow(
                    title: "歌单更新",
                    subtitle: "关注的歌单有更新时通知",
                    isOn: $playlistUpdateEnabled
                )
                
                Divider().padding(.leading, 16)
                
                SettingsToggleRow(
                    title: "艺术家动态",
                    subtitle: "关注的艺术家发布新内容时通知",
                    isOn: $artistUpdateEnabled
                )
            }
            
            // 社交通知
            SettingsGroupHeader(title: "社交通知")
            
            SettingsCard {
                SettingsToggleRow(
                    title: "评论通知",
                    subtitle: "有人评论你的内容时通知",
                    isOn: $commentEnabled
                )
                
                Divider().padding(.leading, 16)
                
                SettingsToggleRow(
                    title: "点赞通知",
                    subtitle: "有人点赞你的内容时通知",
                    isOn: $likeEnabled
                )
                
                Divider().padding(.leading, 16)
                
                SettingsToggleRow(
                    title: "新粉丝通知",
                    subtitle: "有新用户关注你时通知",
                    isOn: $followEnabled
                )
            }
            
            // 系统通知
            SettingsGroupHeader(title: "系统通知")
            
            SettingsCard {
                SettingsToggleRow(
                    title: "系统消息",
                    subtitle: "接收重要的系统通知",
                    isOn: $systemEnabled
                )
                
                Divider().padding(.leading, 16)
                
                SettingsToggleRow(
                    title: "活动推广",
                    subtitle: "接收优惠活动和推广信息",
                    isOn: $promotionEnabled
                )
            }
            
            // 提示
            Text("关闭通知后，您可能会错过重要信息。您可以随时在系统设置中管理通知权限。")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 16)
        }
        .onAppear {
            checkNotificationPermission()
        }
        .alert("通知权限", isPresented: $showPermissionAlert) {
            Button("去设置") {
                openSystemSettings()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请在系统设置中开启通知权限，以便接收推送消息。")
        }
    }
    
    // MARK: - 系统通知权限区域
    private var systemNotificationSection: some View {
        VStack(spacing: 0) {
            SettingsGroupHeader(title: "推送通知")
            
            SettingsCard {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("允许推送通知")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        Text(systemPermissionGranted ? "已开启" : "已关闭（需在系统设置中开启）")
                            .font(.system(size: 13))
                            .foregroundColor(systemPermissionGranted ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    if systemPermissionGranted {
                        Toggle("", isOn: $pushEnabled)
                            .labelsHidden()
                            .tint(.purple)
                    } else {
                        Button("开启") {
                            showPermissionAlert = true
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purple)
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - 方法
    
    /// 检查通知权限
    private func checkNotificationPermission() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                systemPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// 打开系统设置
    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NotificationSettingsView()
}
