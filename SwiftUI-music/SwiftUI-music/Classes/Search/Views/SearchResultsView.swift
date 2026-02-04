//
//  SearchResultsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SearchResultsView: View {
    let searchText: String
    
    // 模拟搜索结果数据
    private var searchResults: [SearchResult] {
        // 简单模拟搜索逻辑，实际应用中应该使用更复杂的搜索算法
        if searchText.isEmpty {
            return []
        }
        
        // 从MusicData中筛选匹配的歌曲
        let songResults = MusicData.recentlyPlayed
            .filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.artist.localizedCaseInsensitiveContains(searchText) }
            .map { SearchResult(id: $0.id, title: $0.title, subtitle: $0.artist, imageUrl: $0.imageUrl, type: .song) }
        
        // 模拟一些艺术家结果
        let artistResults = ["周杰伦", "陈奕迅", "林俊杰", "Taylor Swift"]
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .map { artist -> SearchResult in
                let imageUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDF8fHBvcnRyYWl0fGVufDB8fDB8fHww"
                return SearchResult(id: UUID(), title: artist, subtitle: "艺术家", imageUrl: imageUrl, type: .artist)
            }
        
        // 模拟一些专辑结果
        let albumResults = ["Jay", "范特西", "叶惠美", "魔杰座"]
            .filter { $0.localizedCaseInsensitiveContains(searchText) }
            .map { album -> SearchResult in
                let imageUrl = "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
                return SearchResult(id: UUID(), title: album, subtitle: "周杰伦 · 专辑", imageUrl: imageUrl, type: .album)
            }
        
        return songResults + artistResults + albumResults
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if searchResults.isEmpty {
                // 无搜索结果
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
            } else {
                // 搜索结果列表
                Text("搜索结果")
                    .font(.system(size: 18, weight: .bold))
                
                ForEach(searchResults) { result in
                    SearchResultRow(result: result)
                }
            }
        }
    }
}

// 搜索结果行
struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // 结果图片
            AsyncImage(url: URL(string: result.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: result.type.iconName)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(
                result.type == .artist ? 
                AnyShape(Circle()) : 
                AnyShape(RoundedRectangle(cornerRadius: 8))
            )
            
            // 结果文本
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
    }
}

// 搜索结果模型
struct SearchResult: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageUrl: String
    let type: SearchResultType
}

// 搜索结果类型
enum SearchResultType {
    case song, artist, album
    
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

#Preview {
    SearchResultsView(searchText: "周杰伦")
        .padding()
}
