//
//  HomeView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  首页视图 - 支持 iPhone/iPad 响应式布局
//

import SwiftUI
import UIKit

struct HomeView: View {
    @Environment(\.isWideLayout) private var isWideLayout
    @State private var searchText = ""
    let username = "小明"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部欢迎语和头像
                    headerSection
                    
                    // 搜索框
                    searchBar
                    
                    // 为你推荐
                    recommendationSection
                    
                    // 热门歌单
                    playlistSection
                    
                    // 最近播放
                    recentlyPlayedSection
                }
                .padding(.horizontal, isWideLayout ? 32 : 16)
                .padding(.top, 16)
                .frame(maxWidth: isWideLayout ? 900 : .infinity, alignment: .leading)
                .frame(maxWidth: .infinity) // 在 iPad 上居中显示
            }
        }
    }
    
    // MARK: - 顶部欢迎语和头像
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("你好，\(username)")
                    .font(.system(size: isWideLayout ? 28 : 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("享受美妙的音乐时光")
                    .font(.system(size: isWideLayout ? 18 : 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 用户头像
            ZStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: isWideLayout ? 50 : 40, height: isWideLayout ? 50 : 40)
                
                Text(username.prefix(2))
                    .font(.system(size: isWideLayout ? 20 : 16, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
    
    // MARK: - 搜索框
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .padding(.leading, 8)
            
            TextField("搜索歌曲、艺术家或专辑", text: $searchText)
                .font(.system(size: isWideLayout ? 18 : 14))
            
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
        .padding(isWideLayout ? 12 : 8)
        .background(Color(.systemGray6))
        .cornerRadius(isWideLayout ? 24 : 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - 为你推荐
    private var recommendationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("为你推荐")
                .font(.system(size: isWideLayout ? 22 : 18, weight: .bold))
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isWideLayout ? 20 : 16) {
                    ForEach(MusicData.recommendations) { card in
                        RecommendationCardView(card: card)
                            .frame(width: isWideLayout ? 280 : 200)
                    }
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - 热门歌单
    private var playlistSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("热门歌单")
                    .font(.system(size: isWideLayout ? 22 : 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("查看全部")
                    .font(.system(size: isWideLayout ? 18 : 14))
                    .foregroundColor(.purple)
            }
            
            // 使用自适应列数的网格布局
            let columns = isWideLayout ? 
                [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] :
                [GridItem(.flexible()), GridItem(.flexible())]
            
            LazyVGrid(columns: columns, spacing: isWideLayout ? 20 : 16) {
                ForEach(MusicData.playlists) { playlist in
                    PlaylistCardView(playlist: playlist)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - 最近播放
    private var recentlyPlayedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("最近播放")
                .font(.system(size: isWideLayout ? 22 : 18, weight: .bold))
                .foregroundColor(.primary)
            
            // 宽屏上使用网格布局，其他使用列表布局
            if isWideLayout {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(MusicData.recentlyPlayed) { song in
                        RecentlyPlayedItemView(song: song)
                            .background(Color(.systemGray6).opacity(0.5))
                            .cornerRadius(12)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(MusicData.recentlyPlayed) { song in
                        RecentlyPlayedItemView(song: song)
                        if song.id != MusicData.recentlyPlayed.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        // iPad 横屏底部播放器更大，需要更多空间
        .padding(.bottom, isWideLayout ? 140 : 100)
    }
}


#Preview {
    HomeView()
}
