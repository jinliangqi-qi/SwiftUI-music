//
//  LyricsView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct LyricsView: View {
    // 模拟歌词数据
    private let lyrics = [
        "你听见 风声了吗",
        "风声吹动树叶飘动就像我的心",
        "动着摇着"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            Text("歌词")
                .font(.system(size: 14, weight: .medium))
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                ForEach(0..<lyrics.count, id: \.self) { index in
                    Text(lyrics[index])
                        .font(.system(size: 14))
                        .fontWeight(index == 1 ? .medium : .regular)
                        .opacity(index == 1 ? 1.0 : 0.7)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    LyricsView()
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}