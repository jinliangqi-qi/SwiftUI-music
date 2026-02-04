//
//  EmailSecurityView.swift
//  SwiftUI-music
//
//  邮箱与安全设置页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 邮箱与安全视图
struct EmailSecurityView: View {
    @StateObject private var authService = AuthService.shared
    
    @State private var showChangePassword = false
    @State private var showChangeEmail = false
    @State private var showDeleteAccount = false
    
    var body: some View {
        SettingsDetailContainer(title: "邮箱与安全") {
            // 账号安全
            SettingsGroupHeader(title: "账号安全")
            
            SettingsCard {
                SettingsRow(
                    title: "绑定邮箱",
                    value: maskedEmail,
                    showChevron: true
                ) {
                    showChangeEmail = true
                }
                
                Divider().padding(.leading, 16)
                
                SettingsRow(
                    title: "修改密码",
                    subtitle: "定期修改密码可提高账号安全性",
                    showChevron: true
                ) {
                    showChangePassword = true
                }
            }
            
            // 登录安全
            SettingsGroupHeader(title: "登录安全")
            
            SettingsCard {
                SettingsRow(
                    title: "登录设备管理",
                    subtitle: "查看和管理已登录的设备",
                    showChevron: true
                )
                
                Divider().padding(.leading, 16)
                
                SettingsRow(
                    title: "登录记录",
                    subtitle: "查看最近的登录活动",
                    showChevron: true
                )
            }
            
            // 危险操作
            SettingsGroupHeader(title: "危险操作")
            
            SettingsCard {
                Button(action: { showDeleteAccount = true }) {
                    HStack {
                        Text("注销账号")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                }
            }
            
            Text("注销账号后，您的所有数据将被永久删除且无法恢复。")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 8)
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .sheet(isPresented: $showChangeEmail) {
            ChangeEmailView()
        }
        .alert("确认注销账号", isPresented: $showDeleteAccount) {
            Button("取消", role: .cancel) {}
            Button("确认注销", role: .destructive) {}
        } message: {
            Text("注销后所有数据将被永久删除，此操作不可撤销。")
        }
    }
    
    private var maskedEmail: String {
        guard let email = authService.currentUser?.email else { return "未绑定" }
        let parts = email.components(separatedBy: "@")
        guard parts.count == 2 else { return email }
        
        let name = parts[0]
        let domain = parts[1]
        
        if name.count <= 2 {
            return "\(name)***@\(domain)"
        } else {
            let prefix = String(name.prefix(2))
            let suffix = String(name.suffix(1))
            return "\(prefix)***\(suffix)@\(domain)"
        }
    }
}

#Preview {
    EmailSecurityView()
}
