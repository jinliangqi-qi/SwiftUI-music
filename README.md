# SwiftUI音乐应用项目说明文档

## 项目概述

[点击下载项目](https://gitee.com/qijinliangcom_admin/swift-podcasts)

本项目是一个基于SwiftUI开发的音乐应用，提供了丰富的音乐播放和管理功能，包括首页推荐、搜索、资料库、个人资料和设置等核心页面。应用采用了现代化的UI设计，流畅的动画效果，以及符合人体工程学的交互体验。

### 技术特性

- **兼容性**：iOS 26+、iPadOS、Swift 6
- **架构模式**：MVVM + 单例模式
- **并发安全**：@MainActor、Sendable、async/await
- **响应式编程**：Combine + @Published

## 应用架构

应用采用了标签式导航结构，主要包含以下几个核心页面：

*   首页（Home）：展示推荐内容、热门歌单和最近播放
*   搜索（Search）：提供音乐搜索功能和热门分类
*   资料库（Library）：管理用户的音乐收藏和播放列表
*   个人资料（Profile）：展示用户信息和音乐活动
*   设置（Settings）：提供应用配置选项

此外，应用还包含一个全局的播放器界面和迷你播放器，用于控制音乐播放。

## 核心功能模块

### 🎵 音频播放引擎（AudioPlayerManager）

位置：`Core/Audio/AudioPlayerManager.swift`

基于 AVFoundation 实现的完整音频播放引擎，提供：

- **播放控制**：播放/暂停/上一首/下一首
- **进度管理**：实时播放进度和拖动定位
- **循环模式**：单曲循环/列表循环/随机播放
- **后台播放**：支持后台音频播放和锁屏控制
- **收藏功能**：集成 StorageManager 的收藏管理

```swift
// 使用示例
AudioPlayerManager.shared.play(song: song, playlist: songs)
AudioPlayerManager.shared.togglePlayPause()
AudioPlayerManager.shared.seek(to: 0.5) // 跳转到 50%
```

### 🔍 搜索服务（SearchService）

位置：`Core/Services/SearchService.swift`

智能搜索服务，支持：

- **本地搜索**：歌曲、艺术家、专辑多维度搜索
- **防抖处理**：避免频繁搜索请求
- **搜索历史**：自动保存和管理搜索记录
- **搜索建议**：智能推荐搜索词
- **热门搜索**：展示热门搜索关键词

```swift
// 使用示例
await SearchService.shared.search(query: "周杰伦")
SearchService.shared.addToSearchHistory("林俊杰")
SearchService.shared.getSearchSuggestions(for: "陈")
```

### 💾 本地存储（StorageManager）

位置：`Core/Storage/StorageManager.swift`

使用 UserDefaults 的持久化存储管理，包含：

- **收藏管理**：喜欢的歌曲增删查
- **播放历史**：记录播放过的歌曲
- **搜索历史**：保存搜索记录
- **下载管理**：已下载歌曲的管理
- **设置存储**：用户偏好设置保存

```swift
// 使用示例
StorageManager.shared.addLikedSong(song)
StorageManager.shared.getLikedSongs()
StorageManager.shared.addToPlayHistory(song)
```

### 🌐 网络层（NetworkManager）

位置：`Core/Network/NetworkManager.swift`

网络请求封装层，支持：

- **搜索 API**：音乐搜索接口
- **推荐 API**：个性化推荐数据
- **歌曲详情**：获取歌曲完整信息
- **歌词获取**：获取歌曲歌词
- **模拟数据**：无后端时的演示模式

```swift
// 使用示例
let results = try await NetworkManager.shared.search(query: "夜曲")
let recommendations = try await NetworkManager.shared.getRecommendations()
```

### 👤 用户认证（AuthService）

位置：`Core/Services/AuthService.swift`

完整的用户认证服务：

- **登录/注册**：邮箱密码认证
- **社交登录**：Apple/微信/QQ 登录支持
- **会话管理**：自动登录和会话保持
- **用户信息**：用户资料管理
- **安全退出**：安全的登出流程

```swift
// 使用示例
try await AuthService.shared.login(email: "user@example.com", password: "123456")
try await AuthService.shared.register(email: "user@example.com", password: "123456", username: "用户名")
AuthService.shared.logout()
```

### ⬇️ 下载管理（DownloadManager）

位置：`Core/Services/DownloadManager.swift`

离线下载功能：

- **下载队列**：支持多任务下载队列
- **进度跟踪**：实时下载进度显示
- **断点续传**：支持下载中断恢复
- **本地管理**：已下载文件的管理
- **存储优化**：智能存储空间管理

```swift
// 使用示例
await DownloadManager.shared.download(song: song)
DownloadManager.shared.pauseDownload(songId: song.id)
DownloadManager.shared.getLocalURL(for: song)
```

## 项目目录结构

```
SwiftUI-music/
├── Core/                           # 核心功能模块
│   ├── Audio/
│   │   └── AudioPlayerManager.swift    # 音频播放引擎
│   ├── Network/
│   │   └── NetworkManager.swift        # 网络请求管理
│   ├── Storage/
│   │   └── StorageManager.swift        # 本地存储管理
│   └── Services/
│       ├── AuthService.swift           # 用户认证服务
│       ├── DownloadManager.swift       # 下载管理器
│       └── SearchService.swift         # 搜索服务
├── Classes/                        # 业务模块
│   ├── Auth/
│   │   └── Views/
│   │       └── LoginView.swift         # 登录/注册页面
│   ├── Home/                           # 首页模块
│   ├── Search/                         # 搜索模块
│   ├── Library/                        # 资料库模块
│   ├── Profile/                        # 个人资料模块
│   ├── Player/                         # 播放器模块
│   ├── Setting/                        # 设置模块
│   │   ├── SettingsView.swift          # 设置主页面
│   │   ├── Models/
│   │   │   └── SettingsNavigation.swift    # 设置导航路由
│   │   ├── Views/
│   │   │   └── SettingsDetailContainer.swift   # 可复用组件
│   │   └── Pages/                      # 设置子页面
│   │       ├── ProfileEditView.swift       # 个人资料编辑
│   │       ├── EmailSecurityView.swift     # 邮箱与安全
│   │       ├── NotificationSettingsView.swift  # 通知设置
│   │       ├── AudioQualitySettingsView.swift  # 音频质量
│   │       ├── EqualizerView.swift         # 均衡器
│   │       ├── AboutView.swift             # 关于我们
│   │       ├── HelpFeedbackView.swift      # 帮助与反馈
│   │       └── PrivacyPolicyView.swift     # 隐私政策
│   └── Main/                           # 主框架
├── Models/                         # 数据模型
│   └── MusicModels.swift               # 音乐相关模型
├── Utils/                          # 工具类
└── Resources/                      # 资源文件
```

### 1. 首页（HomeView）

首页是用户进入应用的第一个界面，主要展示个性化推荐内容和热门音乐。

#### 功能组件

*   **顶部欢迎区**：显示用户名和欢迎语，右侧是用户头像
*   **搜索框**：快速进入搜索功能
*   **推荐卡片**：横向滚动的推荐内容卡片
*   **热门歌单**：网格布局的热门歌单
*   **最近播放**：列表形式展示最近播放的歌曲

#### 代码实现

```swift
struct HomeView: View {
    @State private var searchText = ""
    let username = "小明"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 顶部欢迎语和头像
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("你好，\(username)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("享受美妙的音乐时光")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 用户头像
                        ZStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 40, height: 40)
                            
                            Text(username.prefix(2))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    
                    // 搜索框和其他内容...
                }
            }
        }
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.55.44.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/05a694e3ac98459dbf39f0f3fef80a6a~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=FQ24DuuQvRNIopHZb4rZCEIcxUg%3D)

#### 注意事项

*   首页底部需要预留足够空间（约100pt），以容纳迷你播放器和导航栏
*   推荐卡片使用横向滚动视图，确保滚动流畅且不显示滚动指示器
*   热门歌单使用LazyVGrid布局，确保在不同尺寸设备上都能正确显示
*   最近播放列表项之间使用Divider分隔，提高可读性

### 2. 搜索页面（SearchView）

搜索页面提供了强大的音乐搜索功能，以及热门搜索推荐。

#### 功能组件

*   **搜索栏**：支持实时搜索和清除输入
*   **热门搜索**：展示当前热门搜索词
*   **搜索历史**：记录用户的搜索历史
*   **推荐艺术家**：展示推荐的音乐人
*   **热门分类**：音乐分类快速入口
*   **搜索结果**：根据搜索词展示相关结果

#### 代码实现

```swift
struct SearchView: View {
    // 状态变量
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 搜索框
                SearchBarView(searchText: $searchText, isSearching: $isSearching)
                    .padding(.horizontal)
                    .padding(.top)
                
                if !isSearching {
                    // 热门搜索
                    PopularSearchView()
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 其他组件...
                } else {
                    // 搜索结果视图
                    SearchResultsView(searchText: searchText)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.56.13.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/733e505ff9e943c29d8e1e8b6a9af138~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=aDdKvWK8LwXXkgnbbq%2BDBBx22xw%3D)

#### 注意事项

*   搜索状态（isSearching）控制显示搜索结果还是推荐内容
*   搜索框支持实时输入和清除功能
*   搜索结果应支持分类展示（歌曲、专辑、艺术家等）
*   热门分类使用网格布局，确保在不同尺寸设备上都能正确显示

### 3. 资料库页面（LibraryView）

资料库页面是用户管理个人音乐收藏的中心，提供了多种分类和管理功能。

#### 功能组件

*   **标题栏**：显示页面标题和操作按钮
*   **分段控制器**：切换不同的资料库视图（收藏歌曲、播放列表、已下载）
*   **搜索栏**：在资料库内搜索内容
*   **我喜欢的歌曲**：展示用户收藏的歌曲
*   **最近添加**：展示最近添加到资料库的内容
*   **字母索引列表**：按字母顺序浏览内容

#### 代码实现

```swift
struct LibraryView: View {
    // 状态变量
    @State private var searchText = ""
    @State private var selectedSegment = 0
    
    // 分段选项
    private let segments = ["收藏歌曲", "播放列表", "已下载"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 标题栏
                LibraryHeaderView()
                    .padding(.horizontal)
                    .padding(.top)
                
                // 分段控制器
                SegmentedControlView(selectedIndex: $selectedSegment, segments: segments)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // 其他组件...
            }
        }
        .background(Color(.systemBackground))
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.56.16.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/5e640275d051446e9e84a4e61194af00~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=1TRQqS%2BxoKFOmqVu9m22dS2te2I%3D)

#### 注意事项

*   分段控制器使用自定义实现，确保与应用整体风格一致
*   字母索引列表应支持快速跳转到对应字母的内容
*   资料库搜索应仅在当前选中的分段内进行
*   最近添加区域使用横向滚动，方便快速浏览

### 4. 个人资料页面（ProfileView）

个人资料页面展示用户的个人信息和音乐活动，是用户个性化体验的中心。

#### 功能组件

*   **个人信息头部**：展示用户头像、用户名和背景图
*   **用户数据统计**：显示收藏数、播放列表数、关注数和粉丝数
*   **收听统计**：展示用户的音乐收听数据和趋势
*   **喜爱的艺术家**：展示用户喜爱的音乐人
*   **最近活动**：记录用户的音乐相关活动

#### 代码实现

```swift
struct ProfileView: View {
    // 用户数据
    let username = "小明"
    let userHandle = "@xiaoming"
    let avatarUrl = "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBvcnRyYWl0fGVufDB8fDB8fHww"
    let backgroundUrl = "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bXVzaWN8ZW58MHx8MHx8fDA%3D"
    
    // 其他数据...
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 用户信息头部
                ProfileHeaderView(
                    username: username,
                    userHandle: userHandle,
                    avatarUrl: avatarUrl,
                    backgroundUrl: backgroundUrl
                )
                
                // 其他组件...
            }
            .padding(.top, 16)
        }
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.56.18.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/e2de58dc49c94cd594005465bb42c308~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=cAPgikpnCugO2VO2ZkgkzZnCeww%3D)

#### 注意事项

*   个人信息头部使用背景图和头像的组合，创造视觉层次感
*   收听统计使用柱状图展示一周的收听趋势
*   喜爱的艺术家使用圆形头像和网格布局
*   最近活动使用时间线形式展示，清晰表达时间顺序

### 5. 设置页面（SettingsView）

设置页面提供了应用的各种配置选项，让用户可以根据个人偏好定制应用体验。

#### 功能组件

*   **用户信息卡片**：显示用户基本信息
*   **账号设置**：个人资料、邮箱安全、通知设置等
*   **播放设置**：音频质量、均衡器、自动播放等
*   **下载设置**：下载质量、网络限制等
*   **关于与支持**：关于我们、帮助反馈、隐私政策等
*   **退出登录**：退出当前账号

#### 代码实现

```swift
struct SettingsView: View {
    // 状态变量
    @State private var autoPlayEnabled = false
    @State private var wifiOnlyDownload = true
    
    // 用户信息
    private let userName = "小明"
    private let userHandle = "@xiaoming"
    private let avatarUrl = "https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fG11c2ljfGVufDB8fDB8fHww"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 标题
                HStack {
                    Text("设置")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top)
                
                // 用户信息卡片和其他设置项...
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.56.20.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/9e38c27daef144818be6ed6ae10d4f1e~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=wLyvv%2B%2B9azrkJEalkUFtAWOz170%3D)

#### 设置子页面

设置模块包含以下完整的子页面：

##### 5.1 个人资料编辑（ProfileEditView）

位置：`Classes/Setting/Pages/ProfileEditView.swift`

- **头像编辑**：支持更换用户头像
- **用户名修改**：修改显示名称
- **个人简介**：编辑个人介绍文字
- **数据集成**：与 AuthService 集成，实时保存用户信息

##### 5.2 邮箱与安全（EmailSecurityView）

位置：`Classes/Setting/Pages/EmailSecurityView.swift`

- **邮箱管理**：显示绑定邮箱（脱敏显示），支持更换邮箱
- **密码修改**：支持验证旧密码并设置新密码
- **密码强度**：实时显示密码强度提示
- **账号注销**：提供账号删除功能（需二次确认）

##### 5.3 通知设置（NotificationSettingsView）

位置：`Classes/Setting/Pages/NotificationSettingsView.swift`

- **系统权限检测**：使用 `UNUserNotificationCenter` 检测通知权限状态
- **音乐通知**：新歌推送、播放列表更新提醒
- **社交通知**：关注、评论、点赞通知
- **系统通知**：系统更新、活动通知
- **权限引导**：未开启时提供跳转系统设置的引导

##### 5.4 音频质量（AudioQualitySettingsView）

位置：`Classes/Setting/Pages/AudioQualitySettingsView.swift`

- **在线播放质量**：标准/高/无损三档选择
- **下载质量**：独立设置下载音质
- **流量统计**：显示不同音质的预估流量消耗
- **智能推荐**：根据网络环境推荐合适的音质

##### 5.5 均衡器（EqualizerView）

位置：`Classes/Setting/Pages/EqualizerView.swift`

- **预设模式**：流行、摇滚、古典、爵士、电子、自定义等预设
- **频段调节**：支持 60Hz、230Hz、910Hz、3.6kHz、14kHz 五段频率调节
- **自定义垂直滑块**：提供直观的可视化调节界面
- **实时预览**：调节后可实时听到效果变化

##### 5.6 关于我们（AboutView）

位置：`Classes/Setting/Pages/AboutView.swift`

- **应用信息**：显示应用名称、版本号、构建版本
- **功能介绍**：展示应用核心功能特性
- **联系方式**：官网、邮箱、客服热线
- **社交媒体**：微博、微信公众号等社交链接

##### 5.7 帮助与反馈（HelpFeedbackView）

位置：`Classes/Setting/Pages/HelpFeedbackView.swift`

- **常见问题**：FAQ 列表，支持展开/收起查看答案
- **问题反馈**：提供反馈表单，支持选择反馈类型
- **在线客服**：快速连接在线客服
- **联系方式**：邮件支持、电话支持
- **使用教程**：新手引导和使用帮助

##### 5.8 隐私政策（PrivacyPolicyView）

位置：`Classes/Setting/Pages/PrivacyPolicyView.swift`

- **完整政策**：展示完整的隐私政策内容
- **章节划分**：信息收集、使用目的、信息存储、用户权利等章节
- **滚动阅读**：支持长文本滚动阅读

#### 可复用组件

设置模块使用了以下可复用组件（位于 `Classes/Setting/Views/SettingsDetailContainer.swift`）：

- **SettingsDetailContainer**：统一的设置详情页面容器，提供一致的导航栏和布局
- **SettingsCard**：设置项卡片容器，圆角背景样式
- **SettingsRow**：标准设置行，支持标题、副标题、右侧箭头
- **SettingsToggleRow**：带开关的设置行
- **SettingsGroupHeader**：分组标题

#### 注意事项

*   设置页面使用分组式布局，增强可读性和层次感
*   设置项使用统一的样式，包括图标、标题和交互元素
*   所有子页面使用 Sheet 形式呈现，保持导航一致性
*   使用 `@Environment(\.isWideLayout)` 适配 iPad 横屏布局
*   退出登录按钮放在底部，并使用醒目的红色
*   版本信息放在最底部，使用较小的字体

### 6. 播放器页面（PlayerView）

播放器页面是用户控制音乐播放的核心界面，提供了丰富的播放控制功能和歌曲信息展示。

#### 功能组件

*   **顶部导航**：返回按钮和歌曲来源信息
*   **专辑封面**：大尺寸的歌曲封面图
*   **歌曲信息**：歌曲标题和艺术家名称
*   **进度条**：显示播放进度和时间信息
*   **播放控制**：上一首、播放/暂停、下一首等控制按钮
*   **播放模式**：随机播放、循环播放等模式切换
*   **歌词显示**：滚动显示当前播放歌曲的歌词
*   **额外控制**：收藏、分享等功能按钮
*   **音频质量**：显示当前音频质量信息
*   **波形动画**：音乐播放时的视觉效果

#### 代码实现

```swift
struct PlayerView: View {
    // 当前播放的歌曲
    let song: Song
    
    // 播放状态
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 73 // 1:13 in seconds
    @State private var totalTime: Double = 210 // 3:30 in seconds
    @State private var isShuffle: Bool = false
    @State private var repeatMode: RepeatMode = .none
    @State private var isLiked: Bool = false
    
    // 播放模式枚举
    enum RepeatMode {
        case none, one, all
    }
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple.opacity(0.4)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 主内容
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部导航
                    PlayerHeaderView(songSource: "来自：\(song.artist) - 热门单曲")
                    
                    // 专辑封面
                    AlbumCoverView(imageUrl: song.imageUrl)
                    
                    // 歌曲信息
                    SongInfoView(title: song.title, artist: song.artist)
                    
                    // 进度条
                    ProgressBarView(
                        currentTime: $currentTime,
                        totalTime: totalTime
                    )
                    
                    // 播放控制
                    PlayerControlsView(
                        isPlaying: $isPlaying,
                        isShuffle: $isShuffle,
                        repeatMode: $repeatMode
                    )
                    
                    // 其他组件...
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // 添加底部padding，确保内容不被遮挡
            }
        }
        .foregroundColor(.white)
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.56.22.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/ae75e3c35da64ca98e9099a9c2d184f2~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=iQQF4L1J99Ves6P7h5SVSiHigaY%3D)

#### 注意事项

*   播放器使用渐变背景，创造沉浸式体验
*   专辑封面使用阴影和旋转动画，增强视觉效果
*   进度条支持拖动调整播放位置
*   播放控制按钮使用合适的大小和间距，确保易于点击
*   歌词区域支持滚动，当前播放行高亮显示

### 7. 迷你播放器（MiniPlayerView）

迷你播放器是一个全局组件，位于应用底部，提供了快速访问当前播放歌曲的方式。

#### 功能组件

*   **歌曲封面**：小尺寸的歌曲封面图
*   **歌曲信息**：歌曲标题和艺术家名称
*   **播放控制**：播放/暂停和下一首按钮
*   **点击区域**：点击可展开完整播放器

#### 代码实现

```swift
struct MiniPlayerView: View {
    let song: Song
    @State private var isPlaying: Bool = true
    @State private var showPlayerView: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧：歌曲信息
            HStack(spacing: 12) {
                // 歌曲封面
                CachedImageView(urlString: song.imageUrl, cornerRadius: 6)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shineEffect() // 添加闪光效果
                
                // 歌曲信息
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(song.artist)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .onTapGesture {
                withAnimation(AnimationUtils.springAnimation) {
                    showPlayerView = true
                }
            }
            
            Spacer()
            
            // 右侧：播放控制
            HStack(spacing: 16) {
                // 播放/暂停按钮
                Button(action: {
                    withAnimation(AnimationUtils.easeAnimation) {
                        isPlaying.toggle()
                    }
                }) {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        )
                }
                
                // 下一首按钮
                Button(action: {
                    // 下一首歌曲的操作
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .top
        )
        .fullScreenCover(isPresented: $showPlayerView) {
            PlayerView(song: song)
        }
    }
}
```

#### 实现效果

![Simulator Screenshot - iPhone 16 Pro - 2025-03-14 at 15.57.49.png](https://p0-xtjj-private.juejin.cn/tos-cn-i-73owjymdk6/f8b46e2d34e94c7baec67d73345a2d00~tplv-73owjymdk6-jj-mark-v1:0:0:0:0:5o6Y6YeR5oqA5pyv56S-5Yy6IEAg6b2Q6YeR5Lqu:q75.awebp?policy=eyJ2bSI6MywidWlkIjoiMzUyNjg4OTAzMDU2MDM0NCJ9&rk3s=f64ab15b&x-orig-authkey=f32326d3454f2ac7e96d3d06cdbb035152127018&x-orig-expires=1742544309&x-orig-sign=%2FEhQZCz83UPouu3rt0sGPIYBH2U%3D)

#### 注意事项

*   迷你播放器固定在底部，位于标签栏上方
*   使用顶部细线分隔，增强视觉层次感
*   点击左侧区域可展开完整播放器
*   播放/暂停按钮使用紫色圆形背景，增强可见性
*   使用动画过渡到完整播放器，提升用户体验

## 组件复用与设计模式

### 可复用组件

项目中使用了多个可复用组件，提高了代码的可维护性和开发效率：

1.  **CachedImageView**：异步加载和缓存网络图片
2.  **TabBarView**：自定义底部导航栏
3.  **SegmentedControlView**：自定义分段控制器
4.  **AnimationUtils**：统一管理动画效果

### 设计模式

项目采用了以下设计模式：

1.  **MVVM架构**：使用ViewModel分离业务逻辑和UI
2.  **组合模式**：将复杂UI拆分为小型、可复用的组件
3.  **单例模式**：用于管理全局状态和服务
4.  **观察者模式**：通过SwiftUI的@State、@Binding等实现UI与数据的响应式更新

## 性能优化

为确保应用的流畅运行，项目实施了以下性能优化措施：

1.  **图片缓存**：使用CachedImageView减少网络请求和内存占用
2.  **懒加载**：使用LazyVGrid和LazyHGrid延迟加载内容
3.  **视图复用**：通过ForEach和List实现视图的高效复用
4.  **内存管理**：合理使用weak引用和生命周期管理
5.  **搜索防抖**：SearchService 使用防抖机制避免频繁搜索
6.  **单例模式**：核心服务使用单例减少内存开销

## 适配与兼容性

应用在不同设备和系统版本上都能良好运行：

1.  **暗黑模式**：支持系统暗黑模式，自动切换UI样式
2.  **屏幕尺寸**：适配不同尺寸的iPhone和iPad
3.  **系统版本**：支持iOS 26及以上版本
4.  **Swift 版本**：完全兼容 Swift 6，使用 @MainActor 和 Sendable 确保并发安全
5.  **辅助功能**：支持动态字体大小和VoiceOver

## 快速开始

### 环境要求

- Xcode 16.0+
- iOS 26.0+ / iPadOS 26.0+
- Swift 6.0+

### 运行项目

1. 克隆项目到本地
2. 使用 Xcode 打开 `SwiftUI-music.xcodeproj`
3. 选择目标设备或模拟器
4. 点击运行按钮或按 `Cmd + R`

### 主要依赖

- SwiftUI：UI 框架
- AVFoundation：音频播放
- Combine：响应式编程

## 总结

本项目展示了如何使用SwiftUI构建一个功能完善、UI精美的音乐应用。通过模块化设计和组件复用，实现了高效的开发和良好的用户体验。项目中的设计模式和性能优化策略，为构建大型SwiftUI应用提供了有价值的参考。

### 新增核心功能

- ✅ 音频播放引擎（AVFoundation 集成）
- ✅ 智能搜索服务（防抖 + 多维度搜索）
- ✅ 本地存储管理（UserDefaults 持久化）
- ✅ 网络请求层（支持模拟数据）
- ✅ 用户认证服务（登录/注册/社交登录）
- ✅ 下载管理器（离线播放支持）

### 设置模块完整功能

- ✅ 个人资料编辑（头像、用户名、简介）
- ✅ 邮箱与安全（邮箱管理、密码修改、账号注销）
- ✅ 通知设置（系统权限检测、分类通知开关）
- ✅ 音频质量（在线/下载音质、流量统计）
- ✅ 均衡器（预设模式、自定义频段调节）
- ✅ 关于我们（应用信息、联系方式、社交媒体）
- ✅ 帮助与反馈（FAQ、问题反馈、客服支持）
- ✅ 隐私政策（完整政策内容展示）
