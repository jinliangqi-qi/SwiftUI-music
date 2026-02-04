//
//  FavoriteSongsView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct FavoriteSongsView: View {
    var body: some View {
        HStack(spacing: 16) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.indigo]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // 文本信息
            VStack(alignment: .leading, spacing: 4) {
                Text("我喜欢的歌曲")
                    .font(.headline)
                
                Text("32首歌曲")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.indigo.opacity(0.1)]),
            startPoint: .leading,
            endPoint: .trailing
        ))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    FavoriteSongsView()
        .padding()
        .background(Color(.systemBackground))
}
