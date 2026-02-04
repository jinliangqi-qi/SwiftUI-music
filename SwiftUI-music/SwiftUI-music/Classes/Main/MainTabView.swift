//
//  MainTabView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  主标签视图 - 集成全局播放器，支持 iPhone/iPad 双端适配
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        // 使用 GeometryReader 实时获取屏幕尺寸，响应横竖屏切换
        GeometryReader { geometry in
            let isWideLayout = horizontalSizeClass == .regular && geometry.size.width > 700
            
            Group {
                // iPad 横屏使用侧边栏导航，其他情况使用底部标签栏
                if isWideLayout {
                    iPadLandscapeLayout(geometry: geometry)
                } else {
                    compactLayout
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .environment(\.isWideLayout, isWideLayout)
        }
    }
    
    // MARK: - iPad 横屏布局（侧边栏 + 内容区）
    private func iPadLandscapeLayout(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // 左侧边栏
            iPadSidebarView(selectedTab: $selectedTab)
            
            // 分隔线
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 1)
            
            // 主内容区域
            ZStack {
                // 内容页面
                contentView
                
                // 底部悬浮播放器（iPad 大屏版）
                VStack {
                    Spacer()
                    iPadFloatingPlayerView()
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // MARK: - 紧凑布局（iPhone 和 iPad 竖屏共用）
    private var compactLayout: some View {
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
                    .frame(height: DeviceType.isPad ? 80 : 60)
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
    
    // MARK: - 内容视图（根据选中标签显示）
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case 0:
            HomeView()
        case 1:
            SearchView()
        case 2:
            LibraryView()
        case 3:
            ProfileView()
        case 4:
            SettingsView()
        default:
            HomeView()
        }
    }
}

// MARK: - iPad 悬浮播放器
/// iPad 底部悬浮播放器（更大的展示空间）
struct iPadFloatingPlayerView: View {
    @State private var showPlayerView = false
    
    var body: some View {
        Button(action: {
            showPlayerView = true
        }) {
            HStack(spacing: 16) {
                // 专辑封面
                CachedImageView(urlString: MusicData.currentlyPlaying.imageUrl, cornerRadius: 8)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 4)
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(MusicData.currentlyPlaying.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(MusicData.currentlyPlaying.artist)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.3))
                        
                        // 进度
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * 0.35)
                    }
                }
                .frame(width: 150, height: 4)
                
                // 播放控制
                HStack(spacing: 24) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.purple)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.leading, 16)
                
                // 音量控制
                HStack(spacing: 8) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Slider(value: .constant(0.7))
                        .frame(width: 100)
                        .tint(.purple)
                    
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 16)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showPlayerView) {
            PlayerView(song: MusicData.currentlyPlaying)
        }
    }
}

#Preview {
    MainTabView()
}
