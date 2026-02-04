//
//  SettingsItemView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SettingsItemView: View {
    let iconName: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let title: String
    let trailingContent: AnyView
    let action: (() -> Void)?
    
    init(
        iconName: String,
        iconBackgroundColor: Color,
        iconForegroundColor: Color,
        title: String,
        action: (() -> Void)? = nil,
        @ViewBuilder trailingContent: @escaping () -> some View
    ) {
        self.iconName = iconName
        self.iconBackgroundColor = iconBackgroundColor
        self.iconForegroundColor = iconForegroundColor
        self.title = title
        self.action = action
        self.trailingContent = AnyView(trailingContent())
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack {
                // 图标
                Circle()
                    .fill(iconBackgroundColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 14))
                            .foregroundColor(iconForegroundColor)
                    )
                
                // 标题
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .padding(.leading, 12)
                
                Spacer()
                
                // 尾部内容（可以是文本、开关或箭头等）
                trailingContent
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 便捷初始化方法 - 带箭头
extension SettingsItemView {
    static func withChevron(
        iconName: String,
        iconBackgroundColor: Color,
        iconForegroundColor: Color,
        title: String,
        action: @escaping () -> Void
    ) -> SettingsItemView {
        SettingsItemView(
            iconName: iconName,
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            title: title,
            action: action
        ) {
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    // 便捷初始化方法 - 带文本
    static func withText(
        iconName: String,
        iconBackgroundColor: Color,
        iconForegroundColor: Color,
        title: String,
        text: String
    ) -> SettingsItemView {
        SettingsItemView(
            iconName: iconName,
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            title: title
        ) {
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    // 便捷初始化方法 - 带开关
    static func withToggle(
        iconName: String,
        iconBackgroundColor: Color,
        iconForegroundColor: Color,
        title: String,
        isOn: Binding<Bool>
    ) -> SettingsItemView {
        SettingsItemView(
            iconName: iconName,
            iconBackgroundColor: iconBackgroundColor,
            iconForegroundColor: iconForegroundColor,
            title: title
        ) {
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 0) {
        SettingsItemView.withChevron(
            iconName: "person.circle",
            iconBackgroundColor: .purple,
            iconForegroundColor: .purple,
            title: "个人资料",
            action: {}
        )
        Divider()
        SettingsItemView.withText(
            iconName: "speaker.wave.3",
            iconBackgroundColor: .red,
            iconForegroundColor: .red,
            title: "音频质量",
            text: "高清"
        )
        Divider()
        SettingsItemView.withToggle(
            iconName: "wifi",
            iconBackgroundColor: .teal,
            iconForegroundColor: .teal,
            title: "仅WiFi下载",
            isOn: .constant(true)
        )
    }
    .background(Color(.systemBackground))
}
