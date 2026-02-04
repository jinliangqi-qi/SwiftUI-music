//
//  DownloadModels.swift
//  SwiftUI-music
//
//  下载管理模型定义
//  兼容 iOS 18+ / iPadOS / Swift 6
//

import Foundation

// MARK: - 下载状态
/// 下载状态枚举
enum DownloadState: Sendable, Equatable {
    case idle           // 空闲
    case waiting        // 等待中
    case downloading(progress: Double)  // 下载中
    case paused         // 已暂停
    case completed      // 已完成
    case failed(String) // 失败
    
    static func == (lhs: DownloadState, rhs: DownloadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.waiting, .waiting),
             (.paused, .paused),
             (.completed, .completed):
            return true
        case (.downloading(let p1), .downloading(let p2)):
            return p1 == p2
        case (.failed(let e1), .failed(let e2)):
            return e1 == e2
        default:
            return false
        }
    }
}

// MARK: - 下载任务
/// 下载任务模型
struct DownloadTask: Identifiable, Sendable {
    let id: UUID
    let song: Song
    var state: DownloadState
    var progress: Double
    var localUrl: URL?
    var createdAt: Date
    
    init(song: Song) {
        self.id = UUID()
        self.song = song
        self.state = .idle
        self.progress = 0
        self.localUrl = nil
        self.createdAt = Date()
    }
}
