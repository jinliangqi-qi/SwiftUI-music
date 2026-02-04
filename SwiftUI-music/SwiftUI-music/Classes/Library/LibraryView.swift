//
//  LibraryView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
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
                    .padding(.horizontal)
                    .padding(.top)
                
                // 分段控制器
                SegmentedControlView(selectedIndex: $selectedSegment, segments: segments)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // 搜索栏
                LibrarySearchBarView(searchText: $searchText)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                
                // 内容区域
                VStack(spacing: 16) {
                    // 我喜欢的歌曲
                    FavoriteSongsView()
                    
                    // 最近添加
                    RecentlyAddedView()
                        .padding(.horizontal)
                    
                    // 字母索引列表
                    AlphabeticalListView()
                        .padding(.horizontal)
                        .padding(.bottom, 100) // 增加底部间距，为迷你播放器和导航栏留出空间
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    LibraryView()
}
