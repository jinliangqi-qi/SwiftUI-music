//
//  RecommendationCardView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct RecommendationCardView: View {
    let card: RecommendationCard
    
    // 将字符串颜色名称转换为Color对象
    private func getColor(from colorName: String) -> Color {
        switch colorName.lowercased() {
        case "purple": return .purple
        case "indigo": return .indigo
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        case "orange": return .orange
        case "green": return .green
        case "teal": return .teal
        default: return .gray
        }
    }
    
    // 创建渐变色背景
    private var gradientBackground: LinearGradient {
        let colors = card.gradientColors.map { getColor(from: $0) }
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // 渐变色背景
                gradientBackground
                
                // 图片
                CachedImageView(urlString: card.imageUrl)
                    .frame(width: 160, height: 160)
                
                // 底部文字信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(card.description)
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.7))
                }
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 160, height: 160)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            ForEach(MusicData.recommendations) { card in
                RecommendationCardView(card: card)
            }
        }
        .padding()
    }
    .background(Color(.systemBackground))
}
