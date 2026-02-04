//
//  CachedImageView.swift
//  SwiftUI-music
//
//  缓存图片视图 - 支持内存+磁盘双重缓存
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI
import Combine

// MARK: - 图片加载器
/// 图片加载器 - 使用 CacheManager 实现双重缓存
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var loadFailed = false
    
    private var loadTask: Task<Void, Never>?
    private let url: URL
    private let cacheManager = CacheManager.shared
    
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    /// 加载图片
    private func loadImage() {
        let urlString = url.absoluteString
        
        // 1. 检查缓存（内存+磁盘）
        if let cachedImage = cacheManager.getImage(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // 2. 从网络加载
        isLoading = true
        loadFailed = false
        
        loadTask = Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // 检查响应状态
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                // 解码图片
                guard let loadedImage = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                
                // 缓存并显示
                self.cacheManager.setImage(loadedImage, forKey: urlString)
                self.image = loadedImage
                self.isLoading = false
                
            } catch {
                // 加载失败
                if !Task.isCancelled {
                    self.isLoading = false
                    self.loadFailed = true
                    print("❌ 图片加载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 重试加载
    func retry() {
        loadTask?.cancel()
        image = nil
        loadImage()
    }
    
    deinit {
        loadTask?.cancel()
    }
}

// MARK: - 缓存图片视图
/// 缓存图片视图 - 支持加载状态、错误处理和重试
struct CachedImageView: View {
    let urlString: String
    let cornerRadius: CGFloat
    @StateObject private var loader: ImageLoader
    @State private var isLoading = true
    @State private var loadingOpacity = 0.5
    
    init(urlString: String, cornerRadius: CGFloat = 0) {
        self.urlString = urlString
        self.cornerRadius = cornerRadius
        // 安全处理 URL，避免强制解包崩溃
        let url = URL(string: urlString) ?? URL(string: "about:blank")!
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                // 显示图片
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(cornerRadius)
                    .transition(AnimationUtils.fadeTransition)
            } else if loader.loadFailed {
                // 加载失败 - 显示重试按钮
                failedView
            } else {
                // 加载中 - 显示占位符
                loadingView
            }
        }
        .clipped()
    }
    
    /// 加载中视图
    private var loadingView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .cornerRadius(cornerRadius)
            .overlay(
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.purple, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isLoading
                    )
            )
            .opacity(loadingOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    loadingOpacity = 0.8
                }
                isLoading = true
            }
    }
    
    /// 加载失败视图
    private var failedView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .cornerRadius(cornerRadius)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        loader.retry()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                            Text("重试")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.purple)
                    }
                }
            )
    }
}

// MARK: - 便捷初始化
extension CachedImageView {
    init(urlString: String, placeholder: Image = Image(systemName: "photo"), cornerRadius: CGFloat = 0) {
        self.init(urlString: urlString, cornerRadius: cornerRadius)
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: 20) {
        CachedImageView(
            urlString: "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500",
            cornerRadius: 12
        )
        .frame(width: 200, height: 200)
        
        CachedImageView(
            urlString: "https://invalid-url-for-testing",
            cornerRadius: 12
        )
        .frame(width: 200, height: 200)
    }
    .padding()
}
