//
//  ProfileHeaderView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct ProfileHeaderView: View {
    let username: String
    let userHandle: String
    let avatarUrl: String
    let backgroundUrl: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 背景图片
            VStack(spacing: 0) {
                CachedImageView(urlString: backgroundUrl)
                    .frame(height: 160)
                    .overlay(Color.black.opacity(0.4))
                    .clipped()
                
                Color.clear
                    .frame(height: 40)
            }
            
            // 用户信息
            HStack(alignment: .bottom) {
                // 头像
                CachedImageView(urlString: avatarUrl, cornerRadius: 48)
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .shadow(radius: 3)
                    .padding(.leading, 16)
                
                // 用户名称和简介
                VStack(alignment: .leading, spacing: 4) {
                    Text(username)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(userHandle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 12)
                .padding(.bottom, 8)
                
                Spacer()
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    ProfileHeaderView(
        username: "小明",
        userHandle: "@xiaoming",
        avatarUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww",
        backgroundUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
    )
}
