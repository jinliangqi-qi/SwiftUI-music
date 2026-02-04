//
//  SearchBarView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // 搜索输入框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                TextField("搜索歌曲、艺术家或专辑", text: $searchText)
                    .padding(.vertical, 10)
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(20)
            
            // 取消按钮
            if isSearching {
                Button("取消") {
                    searchText = ""
                    isSearching = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.primary)
                .transition(.move(edge: .trailing))
                .animation(.default, value: isSearching)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        @State private var isSearching = false
        
        var body: some View {
            SearchBarView(searchText: $searchText, isSearching: $isSearching)
                .padding()
        }
    }
    
    return PreviewWrapper()
}
