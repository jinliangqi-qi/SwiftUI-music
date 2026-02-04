//
//  LibrarySearchBarView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct LibrarySearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                TextField("在资料库中搜索", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Button(action: {
                // 排序操作
            }) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    LibrarySearchBarView(searchText: .constant(""))
        .padding()
        .background(Color(.systemBackground))
}
