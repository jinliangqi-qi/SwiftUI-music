//
//  PlayerHeaderView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct PlayerHeaderView: View {
    let songSource: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            // 下拉按钮
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // 中间标题
            VStack(spacing: 4) {
                Text("正在播放")
                    .font(.system(size: 14, weight: .medium))
                    .opacity(0.8)
                
                Text(songSource)
                    .font(.system(size: 12))
                    .opacity(0.6)
            }
            
            Spacer()
            
            // 更多选项按钮
            Button(action: {
                // 显示更多选项
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    PlayerHeaderView(songSource: "来自：周杰伦 - 热门单曲")
        .padding()
        .background(Color.purple)
        .foregroundColor(.white)
}