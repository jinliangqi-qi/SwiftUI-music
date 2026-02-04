//
//  CacheSettingsView.swift
//  SwiftUI-music
//
//  缓存管理页面 - 查看和清理缓存
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 缓存管理视图
struct CacheSettingsView: View {
    @StateObject private var cacheManager = CacheManager.shared
    @State private var showClearAlert = false
    @State private var clearType: ClearCacheType = .all
    @State private var isClearing = false
    
    /// 清理缓存类型
    enum ClearCacheType {
        case all
        case image
        case data
        case audio
        
        var title: String {
            switch self {
            case .all: return "所有缓存"
            case .image: return "图片缓存"
            case .data: return "数据缓存"
            case .audio: return "音频缓存"
            }
        }
    }
    
    var body: some View {
        SettingsDetailContainer(title: "缓存管理") {
            // 缓存统计
            SettingsGroupHeader(title: "缓存占用")
            
            SettingsCard {
                // 总缓存
                CacheStatRow(
                    icon: "externaldrive.fill",
                    title: "总缓存",
                    size: cacheManager.totalCacheSize,
                    color: .purple
                )
                
                Divider().padding(.leading, 56)
                
                // 图片缓存
                CacheStatRow(
                    icon: "photo.fill",
                    title: "图片缓存",
                    size: cacheManager.imageCacheSize,
                    color: .blue
                ) {
                    clearType = .image
                    showClearAlert = true
                }
                
                Divider().padding(.leading, 56)
                
                // 数据缓存
                CacheStatRow(
                    icon: "doc.fill",
                    title: "数据缓存",
                    size: cacheManager.dataCacheSize,
                    color: .green
                ) {
                    clearType = .data
                    showClearAlert = true
                }
                
                Divider().padding(.leading, 56)
                
                // 音频缓存
                CacheStatRow(
                    icon: "waveform",
                    title: "音频缓存",
                    size: cacheManager.audioCacheSize,
                    color: .orange
                ) {
                    clearType = .audio
                    showClearAlert = true
                }
            }
            
            // 缓存设置
            SettingsGroupHeader(title: "缓存设置")
            
            SettingsCard {
                SettingsRow(
                    title: "自动清理过期缓存",
                    subtitle: "应用启动时自动清理已过期的缓存",
                    showChevron: false
                )
            }
            
            // 清理操作
            SettingsGroupHeader(title: "清理操作")
            
            SettingsCard {
                // 清除所有缓存
                Button(action: {
                    clearType = .all
                    showClearAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("清除所有缓存")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                            
                            Text("释放 \(cacheManager.formattedSize(cacheManager.totalCacheSize)) 空间")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if isClearing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
                .disabled(isClearing)
            }
            
            // 缓存说明
            VStack(alignment: .leading, spacing: 8) {
                Text("缓存说明")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("• 图片缓存：专辑封面、头像等图片，有效期7天")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("• 数据缓存：搜索结果、推荐数据等，有效期1天")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("• 音频缓存：在线播放时的音频缓存，有效期30天")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text("清理缓存不会影响已下载的歌曲和用户数据")
                    .font(.system(size: 12))
                    .foregroundColor(.purple)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .alert("清除缓存", isPresented: $showClearAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("确定要清除\(clearType.title)吗？此操作不可恢复。")
        }
        .onAppear {
            Task {
                await cacheManager.calculateCacheSize()
            }
        }
    }
    
    /// 清理缓存
    private func clearCache() {
        isClearing = true
        
        Task {
            switch clearType {
            case .all:
                await cacheManager.clearAllCache()
            case .image:
                await cacheManager.clearDiskCache(for: .image)
            case .data:
                await cacheManager.clearDiskCache(for: .data)
            case .audio:
                await cacheManager.clearDiskCache(for: .audio)
            }
            
            await MainActor.run {
                isClearing = false
            }
        }
    }
}

// MARK: - 缓存统计行
struct CacheStatRow: View {
    let icon: String
    let title: String
    let size: Int64
    let color: Color
    var onClear: (() -> Void)? = nil
    
    @StateObject private var cacheManager = CacheManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Text(cacheManager.formattedSize(size))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let onClear = onClear, size > 0 {
                Button(action: onClear) {
                    Text("清除")
                        .font(.system(size: 14))
                        .foregroundColor(.purple)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - 预览
#Preview {
    CacheSettingsView()
}
