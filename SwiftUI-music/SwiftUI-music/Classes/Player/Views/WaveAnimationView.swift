//
//  WaveAnimationView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct WaveAnimationView: View {
    // 动画状态
    @State private var animating = true
    
    var body: some View {
        HStack(spacing: 4) {
            // 创建7个波形条，增加数量使动画更丰富
            ForEach(0..<7) { index in
                WaveBar(delay: Double(index) * 0.15, height: getRandomHeight(for: index))
            }
        }
        .frame(height: 30)
        .padding(.vertical, 8)
        .popInEffect(delay: 0.5) // 添加弹出动画效果
    }
    
    // 为每个波形条生成随机高度，使动画更自然
    private func getRandomHeight(for index: Int) -> Double {
        let baseHeights = [18.0, 24.0, 16.0, 28.0, 20.0, 22.0, 26.0]
        return baseHeights[index % baseHeights.count]
    }
    
    // 单个波形条
    struct WaveBar: View {
        let delay: Double
        let height: Double
        @State private var isAnimating = false
        
        var body: some View {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.9)]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 4, height: isAnimating ? height : 5)
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(delay),
                    value: isAnimating
                )
                .onAppear {
                    // 添加短暂延迟，使动画更自然
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isAnimating = true
                    }
                }
        }
    }
}

#Preview {
    WaveAnimationView()
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}