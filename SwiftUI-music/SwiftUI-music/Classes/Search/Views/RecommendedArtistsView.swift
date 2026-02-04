//
//  RecommendedArtistsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct RecommendedArtistsView: View {
    // 推荐艺术家数据
    private let artists = [
        SearchArtist(name: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDF8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        SearchArtist(name: "Taylor Swift", imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cG9ydHJhaXR8ZW58MHx8MHx8fDA%3D"),
        SearchArtist(name: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        SearchArtist(name: "林俊杰", imageUrl: "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzJ8fHBvcnRyYWl0fGVufDB8fDB8fHww")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("推荐艺术家")
                .font(.system(size: 18, weight: .bold))
            
            // 艺术家网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(artists) { artist in
                    VStack {
                        // 艺术家头像
                        AsyncImage(url: URL(string: artist.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if phase.error != nil {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        
                        // 艺术家名称
                        Text(artist.name)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

// 艺术家模型 - 重命名为SearchArtist以避免与ProfileModels中的Artist冲突
struct SearchArtist: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
}

#Preview {
    RecommendedArtistsView()
        .padding()
}
