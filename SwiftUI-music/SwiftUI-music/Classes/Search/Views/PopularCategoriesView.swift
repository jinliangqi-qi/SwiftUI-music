//
//  PopularCategoriesView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct PopularCategoriesView: View {
    // 热门分类数据
    private let categories = [
        MusicCategory(name: "流行", imageUrl: "https://images.unsplash.com/photo-1499415479124-43c32433a620?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzB8fG11c2ljfGVufDB8fDB8fHww", gradientColors: [Color.purple, Color.indigo]),
        MusicCategory(name: "摇滚", imageUrl: "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fG11c2ljfGVufDB8fDB8fHww", gradientColors: [Color.red, Color.pink]),
        MusicCategory(name: "嘻哈", imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bXVzaWN8ZW58MHx8MHx8fDA%3D", gradientColors: [Color.yellow, Color.orange]),
        MusicCategory(name: "电子", imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D", gradientColors: [Color.green, Color.teal])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("热门分类")
                .font(.system(size: 18, weight: .bold))
            
            // 分类网格
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(categories) { category in
                    ZStack(alignment: .center) {
                        // 背景图片
                        AsyncImage(url: URL(string: category.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Rectangle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: category.gradientColors),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            }
                        }
                        .frame(height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: category.gradientColors.map { $0.opacity(0.7) }),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        
                        // 分类名称
                        Text(category.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// 音乐分类模型
struct MusicCategory: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let gradientColors: [Color]
}

#Preview {
    PopularCategoriesView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
