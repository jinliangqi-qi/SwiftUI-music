//
//  FavoriteArtistsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

// 明确使用Profile模块中的Artist模型
struct FavoriteArtistsView: View {
    let artists: [Artist]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和查看全部按钮
            HStack {
                Text("喜爱的艺术家")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // 查看全部艺术家
                }) {
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(.purple)
                }
            }
            
            // 艺术家列表
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(artists, id: \.id) { artist in
                        VStack(spacing: 4) {
                            // 艺术家头像
                            CachedImageView(urlString: artist.imageUrl)
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                            
                            // 艺术家名称
                            Text(artist.name)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        .frame(width: 64)
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }
}

#Preview {
    FavoriteArtistsView(artists: [
        Artist(name: "周杰伦", imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDF8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "陈奕迅", imageUrl: "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"),
        Artist(name: "林俊杰", imageUrl: "https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzJ8fHBvcnRyYWl0fGVufDB8fDB8fHww")
    ])
    .padding()
    .background(Color(.systemBackground))
}
