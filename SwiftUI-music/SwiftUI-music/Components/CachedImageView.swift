//
//  CachedImageView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI
import Combine

// 图片缓存管理器 - Swift 6 兼容
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private let lock = NSLock()
    
    func get(forKey key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
    
    func set(image: UIImage, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.setObject(image, forKey: key as NSString)
    }
}

// 图片加载器 - 使用 @MainActor 确保 UI 更新在主线程
@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var loadTask: Task<Void, Never>?
    private let url: URL
    private let cache = ImageCache.shared
    
    init(url: URL) {
        self.url = url
        loadImage()
    }
    
    private func loadImage() {
        let urlString = url.absoluteString
        
        // 检查缓存
        if let cachedImage = cache.get(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // 从网络加载 - 使用现代 async/await
        loadTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let loadedImage = UIImage(data: data) {
                    self.image = loadedImage
                    self.cache.set(image: loadedImage, forKey: urlString)
                }
            } catch {
                // 加载失败，保持 image 为 nil
            }
        }
    }
    
    deinit {
        loadTask?.cancel()
    }
}

// 缓存图片视图
// 图片视图组件
struct CachedImageView: View {
    let urlString: String
    let cornerRadius: CGFloat
    @StateObject private var loader: ImageLoader
    @State private var isLoading = true
    @State private var loadingOpacity = 0.5
    
    init(urlString: String, cornerRadius: CGFloat = 0) {
        self.urlString = urlString
        self.cornerRadius = cornerRadius
        _loader = StateObject(wrappedValue: ImageLoader(url: URL(string: urlString)!))
    }
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(cornerRadius)
                    .transition(AnimationUtils.fadeTransition) // 添加淡入动画
            } else {
                // 加载占位符
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
                        // 脉冲动画效果
                        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                            loadingOpacity = 0.8
                        }
                        isLoading = true
                    }
            }
        }
        .clipped()
    }
}

// 便捷初始化方法，支持字符串URL
extension CachedImageView {
    init(urlString: String, placeholder: Image = Image(systemName: "photo"), cornerRadius: CGFloat = 0) {
        self.init(urlString: urlString, cornerRadius: cornerRadius)
    }
}
