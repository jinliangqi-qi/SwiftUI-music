//
//  SettingsDetailContainer.swift
//  SwiftUI-music
//
//  通用设置详情页容器视图
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 设置详情页容器
/// 提供统一的导航栏和布局样式
struct SettingsDetailContainer<Content: View>: View {
    let title: String
    let content: Content
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isWideLayout) private var isWideLayout
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    content
                }
                .frame(maxWidth: isWideLayout ? 600 : .infinity)
                .frame(maxWidth: .infinity)
                .padding(.bottom, isWideLayout ? 40 : 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}

// MARK: - 设置分组卡片
/// 设置项分组卡片容器
struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 设置行视图
/// 通用设置行组件
struct SettingsRow: View {
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var showChevron: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 设置开关行
/// 带开关的设置行
struct SettingsToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.purple)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

// MARK: - 设置分组标题
/// 设置分组标题视图
struct SettingsGroupHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

#Preview {
    SettingsDetailContainer(title: "测试页面") {
        SettingsGroupHeader(title: "基本设置")
        
        SettingsCard {
            SettingsRow(title: "用户名", value: "小明", showChevron: true)
            Divider().padding(.leading, 16)
            SettingsRow(title: "简介", subtitle: "一句话介绍自己", showChevron: true)
            Divider().padding(.leading, 16)
            SettingsToggleRow(title: "启用通知", isOn: .constant(true))
        }
    }
}
