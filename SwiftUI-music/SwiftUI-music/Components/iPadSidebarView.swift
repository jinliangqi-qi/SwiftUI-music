//
//  iPadSidebarView.swift
//  SwiftUI-music
//
//  iPad 侧边栏导航视图
//

import SwiftUI

/// iPad 侧边栏导航视图
struct iPadSidebarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部 Logo 区域
            HStack(spacing: 12) {
                Image(systemName: "music.note.house.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.purple)
                
                Text("音乐")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            
            Divider()
                .padding(.horizontal, 16)
            
            // 导航项目列表
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(SidebarItem.items) { item in
                        SidebarNavButton(
                            item: item,
                            isSelected: selectedTab == item.id,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = item.id
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
            }
            
            Spacer()
        }
        .frame(width: 260)
        .background(Color(.systemGroupedBackground))
    }
}

/// 侧边栏导航按钮
struct SidebarNavButton: View {
    let item: SidebarItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .frame(width: 24)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(item.title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.purple : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// iPad 精简版迷你播放器
struct iPadMiniPlayerView: View {
    var body: some View {
        VStack(spacing: 8) {
            // 专辑封面和歌曲信息
            HStack(spacing: 12) {
                // 专辑封面
                CachedImageView(urlString: MusicData.currentlyPlaying.imageUrl, cornerRadius: 8)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(MusicData.currentlyPlaying.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(MusicData.currentlyPlaying.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // 播放控制
            HStack(spacing: 20) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.purple)
                        .clipShape(Circle())
                }
                
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    iPadSidebarView(selectedTab: .constant(0))
}
