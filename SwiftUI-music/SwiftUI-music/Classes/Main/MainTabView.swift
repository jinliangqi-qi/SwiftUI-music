//
//  MainTabView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  主标签视图 - 集成全局播放器
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                SearchView()
                    .tag(1)
                
                LibraryView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
                
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .safeAreaInset(edge: .bottom) {
                // 为迷你播放器和TabBar预留空间
                Spacer()
                    .frame(height: 60) // 迷你播放器高度 + TabBar高度
                    .frame(maxWidth: .infinity)
            }
            
            // 底部迷你播放器和导航栏
            VStack(spacing: 0) {
                // 迷你播放器
                MiniPlayerView()
                
                // 底部导航栏
                TabBarView(selectedTab: $selectedTab)
            }
            .background(Color(.systemBackground))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainTabView()
}
