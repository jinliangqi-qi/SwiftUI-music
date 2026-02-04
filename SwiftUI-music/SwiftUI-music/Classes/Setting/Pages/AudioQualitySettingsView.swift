//
//  AudioQualitySettingsView.swift
//  SwiftUI-music
//
//  音频质量设置页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 音频质量设置视图
struct AudioQualitySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storageManager = StorageManager.shared
    
    // 选中的质量
    @State private var selectedStreamQuality: AudioQuality = .medium
    @State private var selectedDownloadQuality: AudioQuality = .medium
    
    var body: some View {
        SettingsDetailContainer(title: "音频质量") {
            // 在线播放质量
            SettingsGroupHeader(title: "在线播放")
            
            SettingsCard {
                ForEach(AudioQuality.allCases, id: \.self) { quality in
                    QualityOptionRow(
                        quality: quality,
                        isSelected: selectedStreamQuality == quality
                    ) {
                        selectedStreamQuality = quality
                        storageManager.audioQuality = quality
                    }
                    
                    if quality != AudioQuality.allCases.last {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            
            Text("高质量音频将消耗更多流量，建议在 WiFi 环境下使用。")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            
            // 下载质量
            SettingsGroupHeader(title: "下载质量")
            
            SettingsCard {
                ForEach(AudioQuality.allCases, id: \.self) { quality in
                    QualityOptionRow(
                        quality: quality,
                        isSelected: selectedDownloadQuality == quality
                    ) {
                        selectedDownloadQuality = quality
                        storageManager.downloadQuality = quality
                    }
                    
                    if quality != AudioQuality.allCases.last {
                        Divider().padding(.leading, 16)
                    }
                }
            }
            
            Text("下载质量越高，占用的存储空间越大。")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            
            // 流量预估
            dataUsageInfo
        }
        .onAppear {
            selectedStreamQuality = storageManager.audioQuality
            selectedDownloadQuality = storageManager.downloadQuality
        }
    }
    
    // MARK: - 流量预估信息
    private var dataUsageInfo: some View {
        VStack(spacing: 0) {
            SettingsGroupHeader(title: "流量预估")
            
            SettingsCard {
                VStack(spacing: 12) {
                    DataUsageRow(title: "标准质量", value: "约 1MB/分钟")
                    DataUsageRow(title: "高清质量", value: "约 2MB/分钟")
                    DataUsageRow(title: "无损质量", value: "约 4MB/分钟")
                    DataUsageRow(title: "Hi-Res", value: "约 10MB/分钟")
                }
                .padding(16)
            }
        }
    }
}

// MARK: - 质量选项行
struct QualityOptionRow: View {
    let quality: AudioQuality
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(quality.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        
                        if quality == .lossless {
                            Text("推荐")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.purple)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("\(quality.bitrate) kbps")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.purple)
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 流量使用行
struct DataUsageRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    AudioQualitySettingsView()
}
