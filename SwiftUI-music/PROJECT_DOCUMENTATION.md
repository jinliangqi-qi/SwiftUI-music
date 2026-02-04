# SwiftUI Music App - 项目文档

## 📋 项目概述

SwiftUI Music 是一个使用 SwiftUI 构建的现代音乐播放应用，支持 iOS 18+ 和 iPadOS，采用 Swift 6 并遵循严格的并发安全模型。

### 主要特性
- 🎵 完整的音乐播放功能（播放、暂停、上一首、下一首、进度控制）
- 📱 响应式布局，适配 iPhone 和 iPad
- 🔐 用户认证系统（登录、注册）
- 💾 离线缓存和下载管理
- ⚙️ 丰富的设置选项
- 🎨 现代 UI 设计

---

## 📁 项目结构

项目采用模块化架构，共包含 **81 个 Swift 文件**，每个文件均不超过 300 行代码。

```
SwiftUI-music/
├── SwiftUI_musicApp.swift          # 应用入口
├── Models/                          # 数据模型
│   └── MusicModels.swift           # 音乐相关模型（Song, Album, Artist, Playlist）
├── Components/                      # 可复用组件
│   ├── AnimationUtils.swift        # 动画工具
│   ├── CachedImageView.swift       # 图片缓存视图
│   ├── TabBarView.swift            # 标签栏
│   └── iPadSidebarView.swift       # iPad 侧边栏
├── Classes/                         # 功能模块
│   ├── Auth/                       # 认证模块
│   ├── Home/                       # 首页模块
│   ├── Library/                    # 音乐库模块
│   ├── Main/                       # 主视图模块
│   ├── Player/                     # 播放器模块
│   ├── Profile/                    # 个人资料模块
│   ├── Search/                     # 搜索模块
│   └── Setting/                    # 设置模块
└── Core/                           # 核心服务
    ├── Audio/                      # 音频播放
    ├── Cache/                      # 缓存管理
    ├── Network/                    # 网络请求
    ├── Services/                   # 业务服务
    ├── Storage/                    # 本地存储
    └── Utils/                      # 工具类
```

---

## 🔧 核心模块详解

### 1. 音频播放模块 (Core/Audio/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `AudioPlayerEnums.swift` | 30 | 播放状态和循环模式枚举 |
| `AudioPlayerManager.swift` | 300 | 音频播放管理器主体 |
| `AudioPlayerControls.swift` | 159 | 播放控制扩展（播放、暂停、上下首等） |

**核心类：** `AudioPlayerManager`
- 单例模式 (`@MainActor`)
- 支持真实音频播放和模拟播放
- 后台播放和锁屏控制
- 随机播放和循环模式

### 2. 缓存管理模块 (Core/Cache/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `CacheTypes.swift` | 46 | 缓存类型和元数据模型 |
| `CacheManager.swift` | 203 | 缓存管理器主体（图片和数据缓存） |
| `CacheManagerOperations.swift` | 103 | 缓存清理和统计操作扩展 |

**核心类：** `CacheManager`
- 内存和磁盘双重缓存
- 支持图片、数据、音频缓存
- 自动过期清理
- 缓存大小统计

### 3. 网络模块 (Core/Network/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `NetworkModels.swift` | 120 | API 响应模型和错误类型 |
| `NetworkManager.swift` | 200 | 网络管理器主体 |
| `NetworkManagerHelpers.swift` | 172 | 通用请求方法和模拟数据 |

**核心类：** `NetworkManager`
- RESTful API 请求封装
- 缓存支持
- 错误处理
- 模拟数据生成

### 4. 认证服务 (Core/Services/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `AuthModels.swift` | 85 | 用户、认证状态和错误模型 |
| `AuthService.swift` | 223 | 认证服务主体 |

**核心类：** `AuthService`
- 登录/注册/登出
- Token 管理
- 用户状态管理

### 5. 存储管理 (Core/Storage/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `StorageKeys.swift` | 94 | 存储键定义和辅助模型 |
| `StorageManager.swift` | 237 | 本地存储管理器 |

**核心类：** `StorageManager`
- UserDefaults 封装
- 收藏歌曲管理
- 下载歌曲管理
- 播放历史记录

### 6. 下载管理 (Core/Services/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `DownloadModels.swift` | 42 | 下载状态和任务模型 |
| `DownloadManager.swift` | 246 | 下载管理器 |

**核心类：** `DownloadManager`
- 并发下载控制
- 下载进度跟踪
- 下载队列管理

### 7. 搜索服务 (Core/Services/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `SearchModels.swift` | 77 | 搜索类型和结果模型 |
| `SearchService.swift` | 195 | 搜索服务 |

**核心类：** `SearchService`
- 本地搜索
- 远程搜索
- 搜索历史管理

---

## 📱 UI 模块

### 认证模块 (Classes/Auth/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `LoginView.swift` | 241 | 登录视图 |
| `RegisterView.swift` | 217 | 注册视图 |

### 首页模块 (Classes/Home/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `HomeView.swift` | 184 | 首页主视图 |
| `MiniPlayerView.swift` | 119 | 迷你播放器 |
| `PlaylistCardView.swift` | 61 | 播放列表卡片 |
| `RecentlyPlayedItemView.swift` | 52 | 最近播放项 |
| `RecommendationCardView.swift` | 83 | 推荐卡片 |

### 音乐库模块 (Classes/Library/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `LibraryView.swift` | 58 | 音乐库主视图 |
| `AlphabeticalListView.swift` | 65 | 字母索引列表 |
| `FavoriteSongsView.swift` | 46 | 收藏歌曲 |
| `LibraryHeaderView.swift` | 25 | 头部视图 |
| `LibrarySearchBarView.swift` | 42 | 搜索栏 |
| `RecentlyAddedView.swift` | 62 | 最近添加 |
| `SegmentedControlView.swift` | 37 | 分段控制 |

### 播放器模块 (Classes/Player/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `PlayerView.swift` | 120 | 播放器主视图 |
| `AlbumCoverView.swift` | 26 | 专辑封面 |
| `AudioQualityView.swift` | 20 | 音质显示 |
| `ExtraControlsView.swift` | 79 | 额外控制 |
| `LyricsView.swift` | 36 | 歌词显示 |
| `PlayerControlsView.swift` | 74 | 播放控制 |
| `PlayerHeaderView.swift` | 52 | 播放器头部 |
| `ProgressBarView.swift` | 75 | 进度条 |
| `SongInfoView.swift` | 23 | 歌曲信息 |
| `WaveAnimationView.swift` | 64 | 波形动画 |

### 个人资料模块 (Classes/Profile/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `ProfileView.swift` | 155 | 个人资料主视图 |
| `ProfileModels.swift` | 36 | 个人资料模型 |
| `FavoriteArtistsView.swift` | 79 | 喜爱艺人 |
| `ListeningStatsView.swift` | 96 | 收听统计 |
| `ProfileHeaderView.swift` | 82 | 头部视图 |
| `RecentActivitiesView.swift` | 153 | 最近活动 |
| `UserStatsView.swift` | 71 | 用户统计 |

### 搜索模块 (Classes/Search/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `SearchView.swift` | 123 | 搜索主视图 |
| `PopularCategoriesView.swift` | 111 | 热门分类 |
| `PopularSearchView.swift` | 125 | 热门搜索 |
| `RecommendedArtistsView.swift` | 88 | 推荐艺人 |
| `SearchBarView.swift` | 62 | 搜索栏 |
| `SearchHistoryView.swift` | 82 | 搜索历史 |
| `SearchResultsView.swift` | 279 | 搜索结果 |

### 设置模块 (Classes/Setting/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `SettingsView.swift` | 142 | 设置主视图 |
| `SettingsViewSections.swift` | 200 | 设置区块扩展 |
| `SettingsNavigation.swift` | 70 | 导航模型 |
| `SettingsDetailContainer.swift` | 177 | 详情容器 |
| `SettingsItemView.swift` | 155 | 设置项视图 |
| `SettingsSectionView.swift` | 51 | 设置区块视图 |
| `UserProfileCardView.swift` | 56 | 用户卡片 |

#### 设置子页面 (Classes/Setting/Pages/)

| 文件 | 行数 | 说明 |
|-----|------|------|
| `AboutView.swift` | 224 | 关于我们 |
| `AudioQualitySettingsView.swift` | 172 | 音频质量设置 |
| `CacheSettingsView.swift` | 251 | 缓存管理 |
| `ChangePasswordView.swift` | 256 | 修改密码/邮箱 |
| `EmailSecurityView.swift` | 126 | 邮箱与安全 |
| `EqualizerView.swift` | 241 | 均衡器 |
| `FeedbackFormView.swift` | 143 | 反馈表单 |
| `HelpFeedbackView.swift` | 156 | 帮助与反馈 |
| `NotificationSettingsView.swift` | 187 | 通知设置 |
| `PrivacyPolicyView.swift` | 169 | 隐私政策 |
| `ProfileEditView.swift` | 196 | 编辑个人资料 |

---

## 🏗️ 架构设计

### 设计模式

1. **单例模式**
   - `AudioPlayerManager.shared`
   - `CacheManager.shared`
   - `NetworkManager.shared`
   - `AuthService.shared`
   - `StorageManager.shared`
   - `SearchService.shared`
   - `DownloadManager.shared`

2. **MVVM 架构**
   - View 层：SwiftUI 视图
   - ViewModel 层：`@StateObject` / `@ObservableObject`
   - Model 层：数据模型

3. **扩展模式**
   - 大型类通过 extension 拆分到多个文件
   - 保持单个文件不超过 300 行

### 并发安全

- 使用 `@MainActor` 保护 UI 相关类
- 使用 `Sendable` 协议确保跨线程安全
- 使用 `async/await` 处理异步操作

---

## 📦 依赖

### 系统框架
- SwiftUI
- AVFoundation
- MediaPlayer
- Combine
- CryptoKit

### 最低要求
- iOS 18.0+
- iPadOS 18.0+
- Xcode 16.0+
- Swift 6

---

## 🔄 文件拆分记录

以下文件从原始单文件拆分为多个文件：

| 原始文件 | 原行数 | 拆分后文件 |
|---------|-------|-----------|
| AudioPlayerManager.swift | 595 | AudioPlayerEnums.swift, AudioPlayerManager.swift, AudioPlayerControls.swift |
| NetworkManager.swift | 565 | NetworkModels.swift, NetworkManager.swift, NetworkManagerHelpers.swift |
| LoginView.swift | 501 | LoginView.swift, RegisterView.swift |
| CacheManager.swift | 455 | CacheTypes.swift, CacheManager.swift, CacheManagerOperations.swift |
| AuthService.swift | 423 | AuthModels.swift, AuthService.swift |
| StorageManager.swift | 413 | StorageKeys.swift, StorageManager.swift |
| EmailSecurityView.swift | 385 | EmailSecurityView.swift, ChangePasswordView.swift |
| DownloadManager.swift | 384 | DownloadModels.swift, DownloadManager.swift |
| SettingsView.swift | 382 | SettingsView.swift, SettingsViewSections.swift |
| SearchService.swift | 344 | SearchModels.swift, SearchService.swift |
| HelpFeedbackView.swift | 302 | HelpFeedbackView.swift, FeedbackFormView.swift |

---

## 📝 开发指南

### 添加新功能

1. 在对应的 `Classes/` 目录下创建新视图
2. 如需核心服务，在 `Core/` 目录下添加
3. 确保每个文件不超过 300 行
4. 使用 extension 拆分大型类

### 代码规范

- 使用 `@MainActor` 标记 UI 相关类
- 使用 `private` 或 `internal` 控制访问级别
- 添加 MARK 注释分隔代码区块
- 保持一致的命名风格

---

## 📄 许可证

版权所有 © 2025 金亮大神

---

*文档更新日期：2026年2月4日*
