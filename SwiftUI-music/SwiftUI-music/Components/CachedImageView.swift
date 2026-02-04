//
//  CachedImageView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI
import Combine

// 图片缓存管理器
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// 图片加载器
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private let url: URL
    private var cache = ImageCache.shared
    
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
        
        // 从网络加载
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self, let image = image else { return }
                self.image = image
                self.cache.set(image: image, forKey: urlString)
            }
    }
    
    deinit {
        cancellable?.cancel()
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
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false),
                                value: isLoading
                            )
                    )
                    .opacity(loadingOpacity)
                    .onAppear {
                        // 脉冲动画效果
                        withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
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
