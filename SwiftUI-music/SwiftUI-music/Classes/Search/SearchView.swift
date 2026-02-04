//
//  SearchView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//
//  搜索主视图 - 集成 SearchService 进行搜索
//  兼容 iOS 26、iPad 和 Swift 6

import SwiftUI

// MARK: - 搜索视图
/// 搜索功能的主视图，包含搜索框、热门搜索、搜索历史等
struct SearchView: View {
    @Environment(\.isWideLayout) private var isWideLayout
    
    // MARK: - Properties
    
    /// 搜索文本
    @State private var searchText = ""
    
    /// 是否正在搜索模式
    @State private var isSearching = false
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 搜索框
                SearchBarView(searchText: $searchText, isSearching: $isSearching)
                    .padding(.horizontal, isWideLayout ? 32 : 16)
                    .padding(.top)
                
                if !isSearching {
                    // 非搜索状态 - 显示推荐内容
                    defaultContent
                } else {
                    // 搜索状态 - 显示搜索结果
                    SearchResultsView(searchText: searchText)
                        .padding(.horizontal, isWideLayout ? 32 : 16)
                        .padding(.top, 16)
                        .padding(.bottom, isWideLayout ? 140 : 100)
                }
            }
            .frame(maxWidth: isWideLayout ? 900 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
        // 监听搜索状态变化，保存搜索历史
        .onChange(of: isSearching) { _, newValue in
            // 当退出搜索模式时，保存搜索历史
            if !newValue && !searchText.isEmpty {
                SearchService.shared.addToSearchHistory(searchText)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 默认内容（非搜索状态）
    private var defaultContent: some View {
        VStack(spacing: 0) {
            // 宽屏上使用网格布局
            if isWideLayout {
                wideSearchContent
            } else {
                compactSearchContent
            }
        }
    }
    
    /// 紧凑布局搜索内容（iPhone 和 iPad 竖屏）
    private var compactSearchContent: some View {
        VStack(spacing: 0) {
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
                .padding(.bottom, 100)
        }
    }
    
    /// 宽屏搜索内容（iPad 横屏，两列布局）
    private var wideSearchContent: some View {
        VStack(spacing: 0) {
            // 第一行：热门搜索 + 搜索历史
            HStack(alignment: .top, spacing: 24) {
                PopularSearchView()
                    .frame(maxWidth: .infinity)
                SearchHistoryView()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            // 第二行：推荐艺术家
            RecommendedArtistsView()
                .padding(.horizontal, 32)
                .padding(.top, 24)
            
            // 第三行：热门分类
            PopularCategoriesView()
                .padding(.horizontal, 32)
                .padding(.top, 24)
                .padding(.bottom, 140)
        }
    }
}

// MARK: - Preview
#Preview {
    SearchView()
}
