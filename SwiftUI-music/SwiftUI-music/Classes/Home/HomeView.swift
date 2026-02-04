//
//  HomeView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI
import UIKit

struct HomeView: View {
    @State private var searchText = ""
    let username = "小明"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部欢迎语和头像
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("你好，\(username)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("享受美妙的音乐时光")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 用户头像
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 40, height: 40)
                            
                            Text(username.prefix(2))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // 搜索框
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                        
                        TextField("搜索歌曲、艺术家或专辑", text: $searchText)
                            .font(.system(size: 14))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.bottom, 24)
                    
                    // 为你推荐
                    VStack(alignment: .leading, spacing: 16) {
                        Text("为你推荐")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(MusicData.recommendations) { card in
                                    RecommendationCardView(card: card)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // 热门歌单
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("热门歌单")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("查看全部")
                                .font(.system(size: 14))
                                .foregroundColor(.purple)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(MusicData.playlists) { playlist in
                                PlaylistCardView(playlist: playlist)
                            }
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // 最近播放
                    VStack(alignment: .leading, spacing: 16) {
                        Text("最近播放")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 0) {
                            ForEach(MusicData.recentlyPlayed) { song in
                                RecentlyPlayedItemView(song: song)
                                if song.id != MusicData.recentlyPlayed.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100) // 增加底部间距，为迷你播放器和导航栏留出空间
                }
                .padding(.horizontal, 16)
                .padding(.top, 16) // 使用固定的顶部间距，不再依赖安全区域
            }
        }
    }
}


#Preview {
    HomeView()
}
