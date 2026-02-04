//
//  SettingsSectionView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 分区标题
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 8)
            
            // 分区内容
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    SettingsSectionView(title: "账号") {
        VStack(spacing: 0) {
            SettingsItemView.withChevron(
                iconName: "person.circle",
                iconBackgroundColor: .purple,
                iconForegroundColor: .purple,
                title: "个人资料",
                action: {}
            )
            Divider()
            SettingsItemView.withChevron(
                iconName: "envelope",
                iconBackgroundColor: .green,
                iconForegroundColor: .green,
                title: "邮箱与安全",
                action: {}
            )
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
