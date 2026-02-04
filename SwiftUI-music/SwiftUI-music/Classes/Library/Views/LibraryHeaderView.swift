//
//  LibraryHeaderView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct LibraryHeaderView: View {
    var body: some View {
        HStack {
            Text("资料库")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // 添加播放列表或收藏歌曲的操作
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.purple)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    LibraryHeaderView()
        .padding()
        .background(Color(.systemBackground))
}
