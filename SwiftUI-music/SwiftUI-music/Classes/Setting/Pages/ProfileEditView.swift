//
//  ProfileEditView.swift
//  SwiftUI-music
//
//  个人资料编辑页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 个人资料编辑视图
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    // 编辑状态
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var showImagePicker = false
    @State private var showSaveSuccess = false
    @State private var isSaving = false
    
    var body: some View {
        SettingsDetailContainer(title: "个人资料") {
            // 头像编辑区域
            avatarSection
            
            // 基本信息
            SettingsGroupHeader(title: "基本信息")
            
            SettingsCard {
                // 用户名
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户名")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    TextField("请输入用户名", text: $username)
                        .font(.system(size: 16))
                        .textFieldStyle(.plain)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                Divider().padding(.leading, 16)
                
                // 个人简介
                VStack(alignment: .leading, spacing: 8) {
                    Text("个人简介")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    TextField("一句话介绍自己", text: $bio, axis: .vertical)
                        .font(.system(size: 16))
                        .textFieldStyle(.plain)
                        .lineLimit(3...5)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            
            // 账号信息（只读）
            SettingsGroupHeader(title: "账号信息")
            
            SettingsCard {
                SettingsRow(
                    title: "邮箱",
                    value: authService.currentUser?.email ?? "未绑定"
                )
                
                Divider().padding(.leading, 16)
                
                SettingsRow(
                    title: "注册时间",
                    value: formattedDate(authService.currentUser?.createdAt)
                )
            }
            
            // 保存按钮
            saveButton
        }
        .onAppear {
            loadUserData()
        }
        .alert("保存成功", isPresented: $showSaveSuccess) {
            Button("确定") { dismiss() }
        } message: {
            Text("个人资料已更新")
        }
    }
    
    // MARK: - 头像区域
    private var avatarSection: some View {
        VStack(spacing: 12) {
            // 头像
            Button(action: { showImagePicker = true }) {
                ZStack {
                    if let avatarUrl = authService.currentUser?.avatarUrl {
                        CachedImageView(urlString: avatarUrl, cornerRadius: 50)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(username.prefix(1)))
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(.purple)
                            )
                    }
                    
                    // 编辑图标
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                        .offset(x: 35, y: 35)
                }
            }
            
            Text("点击更换头像")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    // MARK: - 保存按钮
    private var saveButton: some View {
        Button(action: saveProfile) {
            HStack {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("保存修改")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.purple)
            .cornerRadius(12)
        }
        .disabled(isSaving || username.isEmpty)
        .opacity(username.isEmpty ? 0.6 : 1)
        .padding(.horizontal, 16)
        .padding(.top, 32)
    }
    
    // MARK: - 方法
    
    /// 加载用户数据
    private func loadUserData() {
        if let user = authService.currentUser {
            username = user.username
            bio = user.bio ?? ""
        }
    }
    
    /// 保存个人资料
    private func saveProfile() {
        isSaving = true
        
        // 模拟保存延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if var user = authService.currentUser {
                user.username = username
                user.bio = bio.isEmpty ? nil : bio
                authService.updateUser(user)
            }
            isSaving = false
            showSaveSuccess = true
        }
    }
    
    /// 格式化日期
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "未知" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}

#Preview {
    ProfileEditView()
}
