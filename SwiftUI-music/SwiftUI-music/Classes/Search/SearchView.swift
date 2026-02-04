//
//  SearchView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SearchView: View {
    // 状态变量
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 搜索框
                SearchBarView(searchText: $searchText, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top)
                
                if !isSearching {
                    // 热门搜索
                    PopularSearchView()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 搜索历史
                    SearchHistoryView()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 推荐艺术家
                    RecommendedArtistsView()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 热门分类
                    PopularCategoriesView()
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // 增加底部间距，为迷你播放器和导航栏留出空间
                } else {
                    // 搜索结果视图
                    SearchResultsView(searchText: searchText)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // 增加底部间距，为迷你播放器和导航栏留出空间
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    SearchView()
}
