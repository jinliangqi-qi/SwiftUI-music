//
//  TabBarView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Int
    @State private var showPlayerView: Bool = false
    
    var body: some View {
        HStack {
            TabBarButton(imageName: "house", text: "首页", isActive: selectedTab == 0)
                .onTapGesture { 
                    withAnimation(AnimationUtils.springAnimation) {
                        selectedTab = 0 
                    }
                }
            
            TabBarButton(imageName: "magnifyingglass", text: "搜索", isActive: selectedTab == 1)
                .onTapGesture { 
                    withAnimation(AnimationUtils.springAnimation) {
                        selectedTab = 1 
                    }
                }
            
            TabBarButton(imageName: "music.note.list", text: "资料库", isActive: selectedTab == 2)
                .onTapGesture { 
                    withAnimation(AnimationUtils.springAnimation) {
                        selectedTab = 2 
                    }
                }
            
            TabBarButton(imageName: "person", text: "我的", isActive: selectedTab == 3)
                .onTapGesture { 
                    withAnimation(AnimationUtils.springAnimation) {
                        selectedTab = 3 
                    }
                }
            
            TabBarButton(imageName: "gearshape", text: "设置", isActive: selectedTab == 4)
                .onTapGesture { 
                    withAnimation(AnimationUtils.springAnimation) {
                        selectedTab = 4 
                    }
                }
        }
        .padding(.top, 8)
        .padding(.bottom, 30) // 为底部安全区域留出空间
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
        .fullScreenCover(isPresented: $showPlayerView) {
            PlayerView(song: MusicData.currentlyPlaying)
                .transition(AnimationUtils.scaleTransition)
        }
    }
}

// 底部导航按钮
struct TabBarButton: View {
    let imageName: String
    let text: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .purple : .gray)
            
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(isActive ? .purple : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TabBarView(selectedTab: .constant(0))
}
