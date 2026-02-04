//
//  FeedbackFormView.swift
//  SwiftUI-music
//
//  反馈表单视图
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            showSuccess = true
        }
    }
}

#Preview {
    FeedbackFormView()
}
