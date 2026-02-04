//
//  SearchResultsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//
//  搜索结果视图 - 使用 SearchService 进行实时搜索
//  兼容 iOS 26、iPad 和 Swift 6

import SwiftUI

// MARK: - 搜索结果视图
/// 显示搜索结果的视图，集成 SearchService 进行真实搜索
struct SearchResultsView: View {
    // MARK: - Properties
    
    /// 搜索文本（外部传入）
    let searchText: String
    
    /// 是否显示播放器
    @State private var showPlayer = false
    
    /// 选中的歌曲
    @State private var selectedSong: Song?
    
    // MARK: - 计算属性
    
    /// 从 SearchService 获取搜索结果
    private var searchResults: [SearchResult] {
        let service = SearchService.shared
        
        // 将 LocalSearchResults 转换为 SearchResult 数组
        var results: [SearchResult] = []
        
        // 添加歌曲结果
        results.append(contentsOf: service.searchResults.songs.map { song in
            SearchResult(
                id: song.id,
                title: song.title,
                subtitle: song.artist,
                imageUrl: song.imageUrl,
                type: .song
            )
        })
        
        // 添加艺术家结果
        results.append(contentsOf: service.searchResults.artists.map { artist in
            SearchResult(
                id: artist.id,
                title: artist.name,
                subtitle: "艺术家",
                imageUrl: artist.imageUrl,
                type: .artist
            )
        })
        
        // 添加专辑结果
        results.append(contentsOf: service.searchResults.albums.map { album in
            SearchResult(
                id: album.id,
                title: album.name,
                subtitle: "\(album.artist) · 专辑",
                imageUrl: album.imageUrl,
                type: .album
            )
        })
        
        return results
    }
    
    /// 搜索是否正在进行
    private var isSearching: Bool {
        SearchService.shared.isSearching
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 根据搜索状态显示不同内容
            if isSearching {
                // 搜索中 - 显示加载指示器
                loadingView
            } else if searchResults.isEmpty && !searchText.isEmpty {
                // 无搜索结果
                emptyResultsView
            } else if !searchResults.isEmpty {
                // 显示搜索结果列表
                searchResultsList
            }
        }
        // 监听搜索文本变化，触发搜索
        .onChange(of: searchText) { _, newValue in
            SearchService.shared.search(query: newValue)
        }
        // 视图出现时执行初始搜索
        .onAppear {
            if !searchText.isEmpty && searchResults.isEmpty {
                SearchService.shared.search(query: searchText)
            }
        }
        // 全屏播放器
        .fullScreenCover(isPresented: $showPlayer) {
            if let song = selectedSong {
                PlayerView(song: song)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 加载中视图
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .padding(.bottom, 8)
            
            Text("正在搜索...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    /// 无结果视图
    private var emptyResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
                .padding(.bottom, 8)
            
            Text("未找到与\"\(searchText)\"相关的结果")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text("请尝试其他关键词")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    /// 搜索结果列表
    private var searchResultsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和结果数量
            HStack {
                Text("搜索结果")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Text("\(searchResults.count) 个结果")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            // 结果列表
            ForEach(searchResults) { result in
                SearchResultRow(result: result)
                    .onTapGesture {
                        handleResultTap(result)
                    }
            }
        }
    }
    
    // MARK: - Methods
    
    /// 处理搜索结果点击
    private func handleResultTap(_ result: SearchResult) {
        // 如果是歌曲，播放它
        if result.type == .song {
            // 从 MusicData.allSongs 中查找匹配的歌曲
            if let song = MusicData.allSongs.first(where: { $0.id == result.id }) {
                selectedSong = song
                AudioPlayerManager.shared.play(song: song)
                showPlayer = true
            }
        }
        // 艺术家和专辑的点击处理可以在这里扩展
    }
}

// MARK: - 搜索结果行视图
/// 单个搜索结果的行视图
struct SearchResultRow: View {
    // MARK: - Properties
    let result: SearchResult
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            // 结果图片
            AsyncImage(url: URL(string: result.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    // 加载失败时显示默认图标
                    Image(systemName: result.type.iconName)
                        .foregroundColor(.gray)
                } else {
                    // 加载中
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            // 艺术家使用圆形，其他使用圆角矩形
            .clipShape(result.type == .artist ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 8)))
            
            // 结果文本信息
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.system(size: 16))
                    .lineLimit(1)
                
                Text(result.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 类型图标
            Image(systemName: result.type.iconName)
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // 扩大点击区域
    }
}

// MARK: - 搜索结果模型
/// 搜索结果数据模型
struct SearchResult: Identifiable, Sendable {
    /// 唯一标识符
    let id: UUID
    /// 标题（歌曲名/艺术家名/专辑名）
    let title: String
    /// 副标题（艺术家/描述信息）
    let subtitle: String
    /// 封面图片 URL
    let imageUrl: String
    /// 结果类型
    let type: SearchResultType
}

// MARK: - 搜索结果类型
/// 搜索结果的类型枚举
enum SearchResultType: Sendable {
    case song      // 歌曲
    case artist    // 艺术家
    case album     // 专辑
    
    /// 对应的系统图标名称
    var iconName: String {
        switch self {
        case .song:
            return "music.note"
        case .artist:
            return "person.fill"
        case .album:
            return "square.stack"
        }
    }
}

// MARK: - Preview
#Preview {
    SearchResultsView(searchText: "周杰伦")
        .padding()
}
