//
//  LibraryView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//  资料库视图 - 支持 iPhone/iPad 响应式布局
//

import SwiftUI

struct LibraryView: View {
    // 状态变量
    @State private var searchText = ""
    @State private var selectedSegment = 0
    
    // 分段选项
    private let segments = ["收藏歌曲", "播放列表", "已下载"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 标题栏
                LibraryHeaderView()
                    .adaptiveHorizontalPadding()
                    .padding(.top)
                
                // 分段控制器
                SegmentedControlView(selectedIndex: $selectedSegment, segments: segments)
                    .adaptiveHorizontalPadding()
                    .padding(.vertical, 12)
                
                // 搜索栏
                LibrarySearchBarView(searchText: $searchText)
                    .adaptiveHorizontalPadding()
                    .padding(.bottom, 12)
                
                // 内容区域 - iPad 使用更宽的布局
                VStack(spacing: DeviceType.isPad ? 24 : 16) {
                    // 我喜欢的歌曲
                    FavoriteSongsView()
                    
                    // 最近添加
                    RecentlyAddedView()
                        .adaptiveHorizontalPadding()
                    
                    // 字母索引列表
                    AlphabeticalListView()
                        .adaptiveHorizontalPadding()
                        .adaptiveBottomPadding()
                }
            }
            .frame(maxWidth: AdaptiveSize.maxContentWidth)
            .frame(maxWidth: .infinity) // 在 iPad 上居中显示
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    LibraryView()
}
