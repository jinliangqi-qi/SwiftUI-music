//
//  AudioPlayerEnums.swift
//  SwiftUI-music
//
//  音频播放器枚举定义
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 播放状态枚举
/// 播放器状态
enum PlayerState: Sendable {
    case stopped    // 停止
    case playing    // 播放中
    case paused     // 暂停
    case loading    // 加载中
    case error      // 错误
}

// MARK: - 播放模式枚举
/// 播放循环模式
enum RepeatMode: Int, Sendable, CaseIterable {
    case none = 0   // 不循环
    case one = 1    // 单曲循环
    case all = 2    // 列表循环
    
    /// 切换到下一个模式
    var next: RepeatMode {
        RepeatMode(rawValue: (rawValue + 1) % RepeatMode.allCases.count) ?? .none
    }
}

// MARK: - 数组安全索引扩展
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
