//
//  UserProfileCardView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct UserProfileCardView: View {
    let userName: String
    let userHandle: String
    let avatarUrl: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // 用户头像
                CachedImageView(urlString: avatarUrl, cornerRadius: 8)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                
                // 用户信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(userHandle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 箭头图标
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UserProfileCardView(
        userName: "小明",
        userHandle: "@xiaoming",
        avatarUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww",
        action: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
