//
//  AnimationUtils.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

// 动画工具类，提供全局可复用的动画效果
struct AnimationUtils {
    // 标准动画时长
    static let shortDuration: Double = 0.2
    static let mediumDuration: Double = 0.3
    static let longDuration: Double = 0.5
    
    // 常用动画曲线
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let easeAnimation = Animation.easeInOut(duration: mediumDuration)
    static let bounceAnimation = Animation.interpolatingSpring(mass: 1.0, stiffness: 100, damping: 10)
    
    // 页面转场动画
    static let slideTransition = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let fadeTransition = AnyTransition.opacity.animation(.easeInOut(duration: 0.3))
    
    static let scaleTransition = AnyTransition.scale(scale: 0.9)
        .combined(with: .opacity)
        .animation(.easeInOut(duration: 0.3))
    
    // 列表项动画
    static func listItemAnimation(index: Int) -> Animation {
        return .spring(response: 0.4, dampingFraction: 0.7)
            .delay(Double(index) * 0.05) // 级联延迟效果
    }
    
    // 渐变背景动画
    static let gradientAnimation = Animation
        .easeInOut(duration: 3)
        .repeatForever(autoreverses: true)
    
    // 脉冲动画修饰符
    struct PulseEffect: ViewModifier {
        @State private var pulsing = false
        
        func body(content: Content) -> some View {
            content
                .scaleEffect(pulsing ? 1.05 : 1.0)
                .opacity(pulsing ? 0.9 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true),
                    value: pulsing
                )
                .onAppear {
                    pulsing = true
                }
        }
    }
    
    // 闪光效果修饰符
    struct ShineEffect: ViewModifier {
        @State private var animating = false
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .white.opacity(0.5), location: 0.45),
                                        .init(color: .white.opacity(0.5), location: 0.55),
                                        .init(color: .clear, location: 1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(Rectangle())
                            .frame(width: geometry.size.width * 0.7)
                            .offset(x: animating ? geometry.size.width : -geometry.size.width)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .delay(1)
                                    .repeatForever(autoreverses: false),
                                value: animating
                            )
                    }
                )
                .onAppear {
                    animating = true
                }
        }
    }
}

// 视图扩展，方便使用动画效果
extension View {
    // 添加脉冲效果
    func pulseEffect() -> some View {
        modifier(AnimationUtils.PulseEffect())
    }
    
    // 添加闪光效果
    func shineEffect() -> some View {
        modifier(AnimationUtils.ShineEffect())
    }
    
    // 添加弹性出现动画
    func popInEffect(delay: Double = 0) -> some View {
        self.scaleEffect(0.01)
            .opacity(0)
            .onAppear {
                withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.6).delay(delay)) {
                    self.scaleEffect(1)
                    self.opacity(1)
                }
            }
    }
    
    // 添加滑入效果
    func slideInEffect(from edge: Edge, delay: Double = 0) -> some View {
        self.offset(x: edge == .leading ? -50 : (edge == .trailing ? 50 : 0),
                   y: edge == .top ? -50 : (edge == .bottom ? 50 : 0))
            .opacity(0)
            .onAppear {
                withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.7).delay(delay)) {
                    self.offset(x: 0, y: 0)
                    self.opacity(1)
                }
            }
    }
}