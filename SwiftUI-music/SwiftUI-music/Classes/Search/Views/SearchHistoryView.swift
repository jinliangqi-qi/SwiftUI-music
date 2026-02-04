//
//  SearchHistoryView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SearchHistoryView: View {
    // 搜索历史记录
    @State private var searchHistory = [
        "夜曲 周杰伦",
        "陈奕迅",
        "Beyond 海阔天空"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和清除按钮
            HStack {
                Text("搜索历史")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    // 清除所有历史记录
                    searchHistory.removeAll()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        
                        Text("清除")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.gray)
                }
            }
            
            // 历史记录列表
            if searchHistory.isEmpty {
                Text("暂无搜索历史")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            } else {
                VStack(spacing: 16) {
                    ForEach(searchHistory, id: \.self) { item in
                        HStack {
                            // 历史图标
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            
                            // 历史文本
                            Text(item)
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            // 删除按钮
                            Button(action: {
                                // 删除单条历史记录
                                if let index = searchHistory.firstIndex(of: item) {
                                    searchHistory.remove(at: index)
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SearchHistoryView()
        .padding()
}
