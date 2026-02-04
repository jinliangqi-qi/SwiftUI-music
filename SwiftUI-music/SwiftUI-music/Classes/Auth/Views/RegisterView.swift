//
//  RegisterView.swift
//  SwiftUI-music
//
//  注册视图
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 注册视图
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
                    headerSection
                    formSection
                    termsSection
                    registerButton
                    loginLink
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
    
    // MARK: - 子视图
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("创建账号")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("加入我们，开始你的音乐之旅")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            inputField(title: "用户名", icon: "person", text: $username, placeholder: "请输入用户名")
            inputField(title: "邮箱", icon: "envelope", text: $email, placeholder: "请输入邮箱", keyboardType: .emailAddress)
            passwordField(title: "密码", text: $password, placeholder: "请输入密码（至少6位）")
            passwordField(title: "确认密码", text: $confirmPassword, placeholder: "请再次输入密码")
        }
    }
    
    private var termsSection: some View {
        HStack {
            Button(action: { agreeToTerms.toggle() }) {
                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                    .foregroundColor(agreeToTerms ? .purple : .gray)
            }
            
            Text("我同意")
                .foregroundColor(.secondary)
            
            Button(action: { /* 显示条款 */ }) {
                Text("服务条款").foregroundColor(.purple)
            }
            
            Text("和").foregroundColor(.secondary)
            
            Button(action: { /* 显示隐私政策 */ }) {
                Text("隐私政策").foregroundColor(.purple)
            }
        }
        .font(.caption)
    }
    
    private var registerButton: some View {
        Button(action: performRegister) {
            HStack {
                if authService.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("注册").fontWeight(.semibold)
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
    
    private var loginLink: some View {
        HStack {
            Text("已有账号？").foregroundColor(.secondary)
            
            Button(action: { dismiss() }) {
                Text("立即登录")
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
            }
        }
        .font(.subheadline)
    }
    
    // MARK: - 辅助视图
    
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
                Image(systemName: icon).foregroundColor(.gray)
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
    
    private func passwordField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: "lock").foregroundColor(.gray)
                
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
    
    // MARK: - 计算属性
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword &&
        agreeToTerms
    }
    
    // MARK: - 方法
    
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

#Preview {
    RegisterView()
}
