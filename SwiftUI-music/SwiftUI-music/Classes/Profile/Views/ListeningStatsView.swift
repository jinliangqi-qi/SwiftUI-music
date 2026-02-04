//
//  ListeningStatsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct ListeningStatsView: View {
    let stats: ListeningStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("收听统计")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // 本周收听时长
                HStack {
                    Text("本周收听时长")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(stats.weeklyTime)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.purple)
                }
                
                // 统计图表
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(stats.dailyData) { data in
                        VStack(spacing: 4) {
                            // 柱状图
                            Rectangle()
                                .fill(Color.purple.opacity(0.7 + data.percentage * 0.3))
                                .frame(height: 100 * data.percentage)
                                .cornerRadius(4, corners: [.topLeft, .topRight])
                            
                            // 日期标签
                            Text(data.day)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
                .padding(.top, 8)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// 用于设置特定角落的圆角
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

#Preview {
    ListeningStatsView(stats: ListeningStats(
        weeklyTime: "12小时42分钟",
        dailyData: [
            DailyListening(day: "一", percentage: 0.3),
            DailyListening(day: "二", percentage: 0.45),
            DailyListening(day: "三", percentage: 0.6),
            DailyListening(day: "四", percentage: 0.4),
            DailyListening(day: "五", percentage: 0.75),
            DailyListening(day: "六", percentage: 0.9),
            DailyListening(day: "日", percentage: 0.65)
        ]
    ))
    .padding()
    .background(Color(.systemBackground))
}
