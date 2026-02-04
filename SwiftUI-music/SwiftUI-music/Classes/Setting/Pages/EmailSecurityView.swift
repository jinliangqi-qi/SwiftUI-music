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
    
    // 状态
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
            
            // 提示信息
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
            Button("确认注销", role: .destructive) {
                // 执行注销逻辑
            }
        } message: {
            Text("注销后所有数据将被永久删除，此操作不可撤销。")
        }
    }
    
    /// 掩码处理的邮箱
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

// MARK: - 修改密码视图
struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 旧密码
                    PasswordField(title: "当前密码", text: $oldPassword)
                    
                    // 新密码
                    PasswordField(title: "新密码", text: $newPassword)
                    
                    // 确认密码
                    PasswordField(title: "确认新密码", text: $confirmPassword)
                    
                    // 密码要求提示
                    VStack(alignment: .leading, spacing: 4) {
                        Text("密码要求:")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        PasswordRequirement(text: "至少6位字符", isMet: newPassword.count >= 6)
                        PasswordRequirement(text: "两次输入一致", isMet: !newPassword.isEmpty && newPassword == confirmPassword)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    
                    // 错误提示
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // 提交按钮
                    Button(action: changePassword) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("确认修改")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isFormValid ? Color.purple : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || isLoading)
                    .padding(.top, 12)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
        .alert("修改成功", isPresented: $showSuccess) {
            Button("确定") { dismiss() }
        } message: {
            Text("密码已修改，请使用新密码登录")
        }
    }
    
    private var isFormValid: Bool {
        !oldPassword.isEmpty && 
        newPassword.count >= 6 && 
        newPassword == confirmPassword
    }
    
    private func changePassword() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.changePassword(oldPassword: oldPassword, newPassword: newPassword)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - 修改邮箱视图
struct ChangeEmailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var newEmail = ""
    @State private var verificationCode = ""
    @State private var isCodeSent = false
    @State private var countdown = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 新邮箱
                    VStack(alignment: .leading, spacing: 8) {
                        Text("新邮箱地址")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        TextField("请输入新邮箱", text: $newEmail)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                    }
                    
                    // 验证码
                    VStack(alignment: .leading, spacing: 8) {
                        Text("验证码")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            TextField("请输入验证码", text: $verificationCode)
                                .font(.system(size: 16))
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            
                            Button(action: sendCode) {
                                Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .frame(height: 50)
                                    .background(countdown > 0 ? Color.gray : Color.purple)
                                    .cornerRadius(10)
                            }
                            .disabled(countdown > 0 || !isValidEmail)
                        }
                    }
                    
                    // 确认按钮
                    Button(action: {}) {
                        Text("确认修改")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.purple)
                            .cornerRadius(12)
                    }
                    .padding(.top, 12)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("修改邮箱")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
    }
    
    private var isValidEmail: Bool {
        newEmail.contains("@") && newEmail.contains(".")
    }
    
    private func sendCode() {
        countdown = 60
        isCodeSent = true
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - 密码输入框
struct PasswordField: View {
    let title: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack {
                if isSecure {
                    SecureField("请输入", text: $text)
                } else {
                    TextField("请输入", text: $text)
                }
                
                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .font(.system(size: 16))
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
    }
}

// MARK: - 密码要求指示器
struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isMet ? .green : .gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isMet ? .primary : .secondary)
        }
    }
}

#Preview {
    EmailSecurityView()
}
