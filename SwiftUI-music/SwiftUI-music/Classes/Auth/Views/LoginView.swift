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
                    // Logo 和标题
                    headerSection
                    
                    // 登录表单
                    formSection
                    
                    // 登录按钮
                    loginButton
                    
                    // 忘记密码
                    forgotPasswordLink
                    
                    // 分隔线
                    dividerSection
                    
                    // 社交登录
                    socialLoginSection
                    
                    // 注册链接
                    registerLink
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
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
    
    /// 头部区域
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Logo
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            // 标题
            Text("欢迎回来")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 副标题
            Text("登录以继续享受音乐")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    /// 表单区域
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
    
    /// 登录按钮
    private var loginButton: some View {
        Button(action: performLogin) {
            HStack {
                if authService.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("登录")
                        .fontWeight(.semibold)
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
    
    /// 忘记密码链接
    private var forgotPasswordLink: some View {
        Button(action: { showForgotPassword = true }) {
            Text("忘记密码？")
                .font(.subheadline)
                .foregroundColor(.purple)
        }
    }
    
    /// 分隔线
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
    
    /// 社交登录
    private var socialLoginSection: some View {
        VStack(spacing: 12) {
            // Apple 登录
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
            
            // 微信登录
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
    
    /// 注册链接
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
    
    /// 表单是否有效
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@") && password.count >= 6
    }
    
    // MARK: - 方法
    
    /// 执行登录
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

// MARK: - 注册视图
/// 注册视图
struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var agreeToTerms: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("创建账号")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("加入我们，开始你的音乐之旅")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // 表单
                    VStack(spacing: 16) {
                        // 用户名
                        inputField(
                            title: "用户名",
                            icon: "person",
                            text: $username,
                            placeholder: "请输入用户名"
                        )
                        
                        // 邮箱
                        inputField(
                            title: "邮箱",
                            icon: "envelope",
                            text: $email,
                            placeholder: "请输入邮箱",
                            keyboardType: .emailAddress
                        )
                        
                        // 密码
                        passwordField(
                            title: "密码",
                            text: $password,
                            placeholder: "请输入密码（至少6位）"
                        )
                        
                        // 确认密码
                        passwordField(
                            title: "确认密码",
                            text: $confirmPassword,
                            placeholder: "请再次输入密码"
                        )
                    }
                    
                    // 同意条款
                    HStack {
                        Button(action: { agreeToTerms.toggle() }) {
                            Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(agreeToTerms ? .purple : .gray)
                        }
                        
                        Text("我同意")
                            .foregroundColor(.secondary)
                        
                        Button(action: { /* 显示条款 */ }) {
                            Text("服务条款")
                                .foregroundColor(.purple)
                        }
                        
                        Text("和")
                            .foregroundColor(.secondary)
                        
                        Button(action: { /* 显示隐私政策 */ }) {
                            Text("隐私政策")
                                .foregroundColor(.purple)
                        }
                    }
                    .font(.caption)
                    
                    // 注册按钮
                    Button(action: performRegister) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("注册")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isFormValid || authService.isLoading)
                    
                    // 登录链接
                    HStack {
                        Text("已有账号？")
                            .foregroundColor(.secondary)
                        
                        Button(action: { dismiss() }) {
                            Text("立即登录")
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert("注册失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    /// 输入框组件
    private func inputField(
        title: String,
        icon: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    /// 密码输入框组件
    private func passwordField(
        title: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                
                if showPassword {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
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
    
    /// 表单是否有效
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreeToTerms
    }
    
    /// 执行注册
    private func performRegister() {
        Task {
            do {
                try await authService.register(username: username, email: email, password: password)
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
