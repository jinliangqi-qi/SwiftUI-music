//
//  AboutView.swift
//  SwiftUI-music
//
//  关于我们页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 关于我们视图
struct AboutView: View {
    @Environment(\.isWideLayout) private var isWideLayout
    
    // App 信息
    private let appVersion = "1.0.1"
    private let buildNumber = "202207"
    
    var body: some View {
        SettingsDetailContainer(title: "关于我们") {
            // App Logo 和名称
            appInfoSection
            
            // 功能介绍
            SettingsGroupHeader(title: "功能特色")
            
            SettingsCard {
                FeatureRow(icon: "music.note", title: "海量音乐", description: "百万首正版歌曲任你听")
                Divider().padding(.leading, 56)
                FeatureRow(icon: "waveform", title: "高品质音频", description: "支持无损和Hi-Res音质")
                Divider().padding(.leading, 56)
                FeatureRow(icon: "icloud.and.arrow.down", title: "离线播放", description: "下载喜欢的歌曲随时收听")
                Divider().padding(.leading, 56)
                FeatureRow(icon: "person.2", title: "社区互动", description: "与音乐爱好者分享交流")
            }
            
            // 联系我们
            SettingsGroupHeader(title: "联系我们")
            
            SettingsCard {
                ContactRow(icon: "globe", title: "官方网站", value: "www.swiftui-music.com")
                Divider().padding(.leading, 56)
                ContactRow(icon: "envelope", title: "客服邮箱", value: "support@swiftui-music.com")
                Divider().padding(.leading, 56)
                ContactRow(icon: "phone", title: "客服电话", value: "400-888-8888")
            }
            
            // 社交媒体
            SettingsGroupHeader(title: "关注我们")
            
            socialMediaSection
            
            // 法律信息
            legalSection
            
            // 版权信息
            copyrightSection
        }
    }
    
    // MARK: - App 信息区域
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            // App 图标
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
                .frame(width: 100, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.purple.opacity(0.1))
                )
            
            // App 名称
            Text("SwiftUI 音乐")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            // 版本号
            Text("版本 \(appVersion) (\(buildNumber))")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            // 简介
            Text("专注于提供优质音乐体验的现代化应用")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    // MARK: - 社交媒体区域
    private var socialMediaSection: some View {
        HStack(spacing: 24) {
            SocialMediaButton(icon: "message.fill", name: "微信", color: .green)
            SocialMediaButton(icon: "video.fill", name: "微博", color: .red)
            SocialMediaButton(icon: "play.rectangle.fill", name: "抖音", color: .black)
            SocialMediaButton(icon: "bubble.left.and.bubble.right.fill", name: "QQ", color: .blue)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }
    
    // MARK: - 法律信息
    private var legalSection: some View {
        VStack(spacing: 0) {
            SettingsGroupHeader(title: "法律信息")
            
            SettingsCard {
                SettingsRow(title: "用户协议", showChevron: true)
                Divider().padding(.leading, 16)
                SettingsRow(title: "隐私政策", showChevron: true)
                Divider().padding(.leading, 16)
                SettingsRow(title: "开源许可", showChevron: true)
            }
        }
    }
    
    // MARK: - 版权信息
    private var copyrightSection: some View {
        VStack(spacing: 4) {
            Text("© 2024-2026 SwiftUI Music Team")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Text("保留所有权利")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - 功能特色行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 联系方式行
struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.purple)
                .frame(width: 40, height: 40)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 社交媒体按钮
struct SocialMediaButton: View {
    let icon: String
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(color)
                .cornerRadius(12)
            
            Text(name)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AboutView()
}
