//
//  LoginView.swift
//  SwiftUI-music
//
//  登录视图 - 支持邮箱/手机号登录
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import SwiftUI

/// 登录视图
struct LoginView: View {
    // MARK: - 环境
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    // MARK: - 状态
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showRegister: Bool = false
    @State private var showForgotPassword: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - 视图
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    formSection
                    loginButton
                    forgotPasswordLink
                    dividerSection
                    socialLoginSection
                    registerLink
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .alert("登录失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - 子视图
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("欢迎回来")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("登录以继续享受音乐")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            // 邮箱输入框
            VStack(alignment: .leading, spacing: 8) {
                Text("邮箱")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("请输入邮箱", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // 密码输入框
            VStack(alignment: .leading, spacing: 8) {
                Text("密码")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("请输入密码", text: $password)
                    } else {
                        SecureField("请输入密码", text: $password)
                    }
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: performLogin) {
            HStack {
                if authService.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("登录").fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.purple : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || authService.isLoading)
    }
    
    private var forgotPasswordLink: some View {
        Button(action: { showForgotPassword = true }) {
            Text("忘记密码？")
                .font(.subheadline)
                .foregroundColor(.purple)
        }
    }
    
    private var dividerSection: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("或")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    private var socialLoginSection: some View {
        VStack(spacing: 12) {
            Button(action: { /* Apple 登录 */ }) {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("使用 Apple 登录")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { /* 微信登录 */ }) {
                HStack {
                    Image(systemName: "message.fill")
                    Text("使用微信登录")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    private var registerLink: some View {
        HStack {
            Text("还没有账号？")
                .foregroundColor(.secondary)
            
            Button(action: { showRegister = true }) {
                Text("立即注册")
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
        }
        .font(.subheadline)
    }
    
    // MARK: - 计算属性
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@") && password.count >= 6
    }
    
    // MARK: - 方法
    
    private func performLogin() {
        Task {
            do {
                try await authService.login(email: email, password: password)
                dismiss()
            } catch let error as AuthError {
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - 预览
#Preview {
    LoginView()
}
