//
//  SettingsNavigation.swift
//  SwiftUI-music
//
//  设置页面导航路由定义
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 设置页面路由
/// 设置页面导航枚举
enum SettingsRoute: Hashable, Sendable {
    // 账号设置
    case profile           // 个人资料
    case emailSecurity     // 邮箱与安全
    case notifications     // 通知设置
    
    // 播放设置
    case audioQuality      // 音频质量
    case equalizer         // 均衡器
    
    // 关于与支持
    case about             // 关于我们
    case helpFeedback      // 帮助与反馈
    case privacyPolicy     // 隐私政策
    
    /// 页面标题
    var title: String {
        switch self {
        case .profile: return "个人资料"
        case .emailSecurity: return "邮箱与安全"
        case .notifications: return "通知设置"
        case .audioQuality: return "音频质量"
        case .equalizer: return "均衡器"
        case .about: return "关于我们"
        case .helpFeedback: return "帮助与反馈"
        case .privacyPolicy: return "隐私政策"
        }
    }
}

// MARK: - 均衡器预设
/// 均衡器预设枚举
enum EqualizerPreset: String, CaseIterable, Codable, Sendable {
    case flat = "平坦"
    case pop = "流行"
    case rock = "摇滚"
    case jazz = "爵士"
    case classical = "古典"
    case electronic = "电子"
    case hiphop = "嘻哈"
    case vocal = "人声"
    case custom = "自定义"
    
    /// 各频段增益值 (60Hz, 150Hz, 400Hz, 1kHz, 2.4kHz, 6kHz, 15kHz)
    var gains: [Double] {
        switch self {
        case .flat: return [0, 0, 0, 0, 0, 0, 0]
        case .pop: return [1, 2, 3, 2, 0, 1, 2]
        case .rock: return [4, 2, -1, 1, 3, 4, 3]
        case .jazz: return [3, 1, 0, 1, -1, 2, 3]
        case .classical: return [4, 3, 0, 0, 0, 2, 4]
        case .electronic: return [4, 3, 0, -2, 0, 3, 4]
        case .hiphop: return [4, 3, 1, -1, 2, 3, 2]
        case .vocal: return [-2, 0, 2, 4, 2, 0, -1]
        case .custom: return [0, 0, 0, 0, 0, 0, 0]
        }
    }
}
