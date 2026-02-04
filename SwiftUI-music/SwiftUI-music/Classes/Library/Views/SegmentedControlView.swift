//
//  SegmentedControlView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SegmentedControlView: View {
    @Binding var selectedIndex: Int
    let segments: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<segments.count, id: \.self) { index in
                    Button(action: {
                        selectedIndex = index
                    }) {
                        Text(segments[index])
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedIndex == index ? Color.purple : Color(.systemGray6))
                            .foregroundColor(selectedIndex == index ? .white : .gray)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    SegmentedControlView(selectedIndex: .constant(0), segments: ["收藏歌曲", "播放列表", "已下载"])
        .padding()
        .background(Color(.systemBackground))
}
