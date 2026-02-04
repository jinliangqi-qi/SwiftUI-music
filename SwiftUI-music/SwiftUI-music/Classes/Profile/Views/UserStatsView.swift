//
//  UserStatsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct UserStatsView: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 16) {
            // 用户数据统计
            HStack(spacing: 0) {
                StatItem(value: stats.favorites, label: "收藏")
                StatItem(value: stats.playlists, label: "歌单")
                StatItem(value: stats.following, label: "关注")
                StatItem(value: stats.followers, label: "粉丝")
            }
            
            // 编辑资料和二维码按钮
            HStack(spacing: 12) {
                Button(action: {
                    // 编辑资料操作
                }) {
                    Text("编辑资料")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.purple)
                        .cornerRadius(20)
                }
                
                Button(action: {
                    // 显示二维码操作
                }) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
    }
}

// 统计项目组件
struct StatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    UserStatsView(stats: UserStats(
        favorites: 428,
        playlists: 32,
        following: 286,
        followers: 142
    ))
    .padding()
    .background(Color(.systemBackground))
}
