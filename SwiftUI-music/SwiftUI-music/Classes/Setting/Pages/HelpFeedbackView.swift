//
//  HelpFeedbackView.swift
//  SwiftUI-music
//
//  帮助与反馈页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 帮助与反馈视图
struct HelpFeedbackView: View {
    @State private var showFeedbackForm = false
    
    var body: some View {
        SettingsDetailContainer(title: "帮助与反馈") {
            // 常见问题
            SettingsGroupHeader(title: "常见问题")
            
            SettingsCard {
                FAQRow(question: "如何下载音乐？", answer: "在歌曲或歌单页面点击下载按钮，即可将音乐保存到本地。下载的歌曲可在\"资料库-已下载\"中找到。")
                Divider().padding(.leading, 16)
                FAQRow(question: "为什么无法播放某些歌曲？", answer: "部分歌曲可能因版权限制无法播放。您可以尝试使用VIP会员解锁更多曲目。")
                Divider().padding(.leading, 16)
                FAQRow(question: "如何创建歌单？", answer: "在\"资料库\"页面点击\"+\"按钮，输入歌单名称即可创建。您也可以在播放页面将歌曲添加到歌单。")
                Divider().padding(.leading, 16)
                FAQRow(question: "忘记密码怎么办？", answer: "在登录页面点击\"忘记密码\"，通过绑定的邮箱重置密码。")
                Divider().padding(.leading, 16)
                FAQRow(question: "如何修改音频质量？", answer: "进入\"设置-播放-音频质量\"，可以分别设置在线播放和下载的音质。")
            }
            
            // 问题反馈
            SettingsGroupHeader(title: "问题反馈")
            
            SettingsCard {
                SettingsRow(
                    title: "提交反馈",
                    subtitle: "报告问题或提出建议",
                    showChevron: true
                ) {
                    showFeedbackForm = true
                }
                
                Divider().padding(.leading, 16)
                
                SettingsRow(
                    title: "查看反馈记录",
                    subtitle: "查看已提交的反馈状态",
                    showChevron: true
                )
            }
            
            // 联系客服
            SettingsGroupHeader(title: "联系客服")
            
            SettingsCard {
                HelpContactRow(
                    icon: "headphones",
                    title: "在线客服",
                    subtitle: "工作时间 9:00-21:00",
                    action: "连接"
                )
                
                Divider().padding(.leading, 56)
                
                HelpContactRow(
                    icon: "envelope.fill",
                    title: "邮件支持",
                    subtitle: "support@swiftui-music.com",
                    action: "发送邮件"
                )
                
                Divider().padding(.leading, 56)
                
                HelpContactRow(
                    icon: "phone.fill",
                    title: "电话支持",
                    subtitle: "400-888-8888",
                    action: "拨打"
                )
            }
            
            // 其他帮助
            SettingsGroupHeader(title: "更多帮助")
            
            SettingsCard {
                SettingsRow(title: "使用教程", showChevron: true)
                Divider().padding(.leading, 16)
                SettingsRow(title: "新手引导", showChevron: true)
                Divider().padding(.leading, 16)
                SettingsRow(title: "更新日志", showChevron: true)
            }
        }
        .sheet(isPresented: $showFeedbackForm) {
            FeedbackFormView()
        }
    }
}

// MARK: - FAQ 行
struct FAQRow: View {
    let question: String
    let answer: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - 帮助联系行
struct HelpContactRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: String
    
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
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(action)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.purple)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 反馈表单视图
struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackType = 0
    @State private var feedbackContent = ""
    @State private var contactInfo = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    
    private let feedbackTypes = ["功能建议", "Bug反馈", "内容问题", "其他"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 反馈类型
                    VStack(alignment: .leading, spacing: 8) {
                        Text("反馈类型")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Picker("反馈类型", selection: $feedbackType) {
                            ForEach(0..<feedbackTypes.count, id: \.self) { index in
                                Text(feedbackTypes[index]).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // 反馈内容
                    VStack(alignment: .leading, spacing: 8) {
                        Text("反馈内容")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $feedbackContent)
                            .font(.system(size: 16))
                            .frame(minHeight: 150)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        Text("\(feedbackContent.count)/500")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // 联系方式
                    VStack(alignment: .leading, spacing: 8) {
                        Text("联系方式（选填）")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        TextField("邮箱或手机号，方便我们联系您", text: $contactInfo)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                    }
                    
                    // 提交按钮
                    Button(action: submitFeedback) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("提交反馈")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(feedbackContent.isEmpty ? Color.gray : Color.purple)
                        .cornerRadius(12)
                    }
                    .disabled(feedbackContent.isEmpty || isSubmitting)
                    .padding(.top, 12)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("提交反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.purple)
                }
            }
        }
        .alert("提交成功", isPresented: $showSuccess) {
            Button("确定") { dismiss() }
        } message: {
            Text("感谢您的反馈，我们会尽快处理！")
        }
    }
    
    private func submitFeedback() {
        isSubmitting = true
        
        // 模拟提交
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            showSuccess = true
        }
    }
}

#Preview {
    HelpFeedbackView()
}
