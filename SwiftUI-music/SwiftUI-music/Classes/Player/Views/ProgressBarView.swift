//
//  ProgressBarView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var currentTime: Double
    let totalTime: Double
    
    // 格式化时间为分:秒格式
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景条
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // 进度条
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * CGFloat(currentTime / totalTime), height: 4)
                        .cornerRadius(2)
                    
                    // 拖动手柄
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .offset(x: geometry.size.width * CGFloat(currentTime / totalTime) - 6)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let percentage = min(max(0, value.location.x / geometry.size.width), 1)
                                    currentTime = Double(percentage) * totalTime
                                }
                        )
                }
            }
            .frame(height: 20) // 增加高度以便于触摸
            
            // 时间显示
            HStack {
                Text(formatTime(currentTime))
                    .font(.system(size: 12))
                    .opacity(0.7)
                
                Spacer()
                
                Text(formatTime(totalTime))
                    .font(.system(size: 12))
                    .opacity(0.7)
            }
        }
    }
}

#Preview {
    ProgressBarView(currentTime: .constant(73), totalTime: 210)
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}