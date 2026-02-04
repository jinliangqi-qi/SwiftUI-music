//
//  AlphabeticalListView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct AlphabeticalListView: View {
    // 字母索引
    private let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    @State private var selectedLetter = "A"
    
    // 示例歌曲数据 - 实际应用中应该根据选择的字母筛选
    private let aSongs = [
        Song(title: "爱情转移", artist: "陈奕迅", imageUrl: ""),
        Song(title: "爱在西元前", artist: "周杰伦", imageUrl: ""),
        Song(title: "爱如潮水", artist: "张信哲", imageUrl: "")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            Text("A-Z")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .textCase(.uppercase)
            
            // 字母索引栏
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            selectedLetter = letter
                        }) {
                            Text(letter)
                                .font(.system(size: 14, weight: .medium))
                                .frame(width: 32, height: 32)
                                .background(selectedLetter == letter ? Color.purple : Color(.systemGray6))
                                .foregroundColor(selectedLetter == letter ? .white : .gray)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            // 选中字母的歌曲列表
            VStack(spacing: 16) {
                ForEach(aSongs) { song in
                    SongRowView(song: song)
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    AlphabeticalListView()
        .padding()
        .background(Color(.systemBackground))
}
