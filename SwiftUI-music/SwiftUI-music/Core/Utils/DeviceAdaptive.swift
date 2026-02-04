//
//  DeviceAdaptive.swift
//  SwiftUI-music
//
//  Created for iPad adaptation
//  设备适配工具 - 提供响应式布局支持
//

import SwiftUI

// MARK: - 宽屏布局环境键
/// 用于在视图层级中传递宽屏布局状态
private struct WideLayoutKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    /// 是否使用宽屏布局（iPad 横屏）
    var isWideLayout: Bool {
        get { self[WideLayoutKey.self] }
        set { self[WideLayoutKey.self] = newValue }
    }
}

// MARK: - 设备类型检测
/// 设备适配工具类，用于区分 iPhone 和 iPad
@MainActor
struct DeviceType {
    /// 当前是否为 iPad
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 当前是否为 iPhone
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 当前屏幕宽度（注意：这个值在屏幕旋转时可能不会立即更新）
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    /// 当前屏幕高度
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    /// 是否为横屏模式
    static var isLandscape: Bool {
        screenWidth > screenHeight
    }
}

// MARK: - 自适应网格列数
/// 根据屏幕宽度计算网格列数
@MainActor
struct AdaptiveGridLayout {
    /// 获取自适应的网格列数
    /// - Parameters:
    ///   - minItemWidth: 单个项目的最小宽度
    ///   - spacing: 项目之间的间距
    ///   - horizontalPadding: 水平内边距
    /// - Returns: 适合当前屏幕的列数
    static func columns(minItemWidth: CGFloat = 160, spacing: CGFloat = 16, horizontalPadding: CGFloat = 32) -> Int {
        let availableWidth = DeviceType.screenWidth - horizontalPadding
        let columnsCount = Int((availableWidth + spacing) / (minItemWidth + spacing))
        return max(2, columnsCount) // 最少 2 列
    }
    
    /// 生成自适应的 GridItem 数组
    static func gridItems(minItemWidth: CGFloat = 160, spacing: CGFloat = 16) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns(minItemWidth: minItemWidth, spacing: spacing))
    }
    
    /// 为首页推荐卡片生成列布局（iPhone 2列，iPad 根据宽度自适应）
    static var homePlaylistColumns: [GridItem] {
        if DeviceType.isPad {
            return gridItems(minItemWidth: 180, spacing: 16)
        } else {
            return [GridItem(.flexible()), GridItem(.flexible())]
        }
    }
    
    /// 为资料库生成列布局
    static var libraryColumns: [GridItem] {
        if DeviceType.isPad {
            return gridItems(minItemWidth: 200, spacing: 20)
        } else {
            return [GridItem(.flexible())]
        }
    }
}

// MARK: - 自适应尺寸
/// 响应式尺寸配置
@MainActor
struct AdaptiveSize {
    /// 卡片宽度
    static var cardWidth: CGFloat {
        if DeviceType.isPad {
            return DeviceType.isLandscape ? 220 : 200
        }
        return 160
    }
    
    /// 推荐卡片宽度
    static var recommendationCardWidth: CGFloat {
        if DeviceType.isPad {
            return 280
        }
        return 200
    }
    
    /// 头像大小
    static var avatarSize: CGFloat {
        DeviceType.isPad ? 120 : 96
    }
    
    /// 标题字体大小
    static var titleFontSize: CGFloat {
        DeviceType.isPad ? 28 : 20
    }
    
    /// 副标题字体大小
    static var subtitleFontSize: CGFloat {
        DeviceType.isPad ? 18 : 14
    }
    
    /// Section 标题字体大小
    static var sectionTitleFontSize: CGFloat {
        DeviceType.isPad ? 22 : 18
    }
    
    /// 内容区域最大宽度（iPad 上限制内容宽度）
    static var maxContentWidth: CGFloat {
        DeviceType.isPad ? 900 : .infinity
    }
    
    /// 水平内边距
    static var horizontalPadding: CGFloat {
        DeviceType.isPad ? 32 : 16
    }
    
    /// 底部播放器预留空间
    static var bottomPadding: CGFloat {
        DeviceType.isPad && DeviceType.screenWidth > 700 ? 140 : 100
    }
}

// MARK: - iPad 侧边栏导航项
/// 侧边栏导航项配置
struct SidebarItem: Identifiable {
    let id: Int
    let title: String
    let icon: String
    
    static let items: [SidebarItem] = [
        SidebarItem(id: 0, title: "首页", icon: "house"),
        SidebarItem(id: 1, title: "搜索", icon: "magnifyingglass"),
        SidebarItem(id: 2, title: "资料库", icon: "music.note.list"),
        SidebarItem(id: 3, title: "我的", icon: "person"),
        SidebarItem(id: 4, title: "设置", icon: "gearshape")
    ]
}

// MARK: - View Extensions for Adaptive Layout
extension View {
    /// 应用自适应内容宽度限制
    @MainActor @ViewBuilder
    func adaptiveMaxWidth() -> some View {
        if DeviceType.isPad {
            self.frame(maxWidth: AdaptiveSize.maxContentWidth)
        } else {
            self
        }
    }
    
    /// 应用自适应水平内边距
    @MainActor
    func adaptiveHorizontalPadding() -> some View {
        self.padding(.horizontal, AdaptiveSize.horizontalPadding)
    }
    
    /// 应用自适应底部安全区域
    @MainActor
    func adaptiveBottomPadding() -> some View {
        self.padding(.bottom, AdaptiveSize.bottomPadding)
    }
}

// MARK: - Environment Key for Size Class
/// 尺寸类别环境键
struct HorizontalSizeClassKey: EnvironmentKey {
    static let defaultValue: UserInterfaceSizeClass? = nil
}

extension EnvironmentValues {
    var horizontalSizeClassValue: UserInterfaceSizeClass? {
        get { self[HorizontalSizeClassKey.self] }
        set { self[HorizontalSizeClassKey.self] = newValue }
    }
}

// MARK: - Preview Helper
#Preview("iPad Layout Test") {
    VStack(spacing: 20) {
        Text("Device: \(DeviceType.isPad ? "iPad" : "iPhone")")
        Text("Screen: \(Int(DeviceType.screenWidth)) x \(Int(DeviceType.screenHeight))")
        Text("Grid Columns: \(AdaptiveGridLayout.columns())")
        Text("Card Width: \(Int(AdaptiveSize.cardWidth))")
        
        LazyVGrid(columns: AdaptiveGridLayout.homePlaylistColumns, spacing: 16) {
            ForEach(0..<6) { i in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.3))
                    .frame(height: 120)
                    .overlay(Text("Item \(i + 1)"))
            }
        }
        .padding(.horizontal, AdaptiveSize.horizontalPadding)
    }
}
