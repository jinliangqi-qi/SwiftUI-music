//
//  EqualizerView.swift
//  SwiftUI-music
//
//  均衡器设置页面
//  兼容 iOS 26+ / iPadOS / Swift 6
//

import SwiftUI

// MARK: - 均衡器视图
struct EqualizerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isWideLayout) private var isWideLayout
    
    // 均衡器状态
    @State private var isEnabled = true
    @State private var selectedPreset: EqualizerPreset = .flat
    @State private var customGains: [Double] = [0, 0, 0, 0, 0, 0, 0]
    
    // 频段标签
    private let frequencies = ["60", "150", "400", "1k", "2.4k", "6k", "15k"]
    
    var body: some View {
        SettingsDetailContainer(title: "均衡器") {
            // 开关
            SettingsCard {
                SettingsToggleRow(
                    title: "启用均衡器",
                    subtitle: "自定义音频频率响应",
                    isOn: $isEnabled
                )
            }
            .padding(.top, 16)
            
            if isEnabled {
                // 预设选择
                SettingsGroupHeader(title: "预设效果")
                
                presetSelector
                
                // 均衡器滑块
                SettingsGroupHeader(title: "频段调节")
                
                equalizerSliders
                
                // 重置按钮
                resetButton
            }
            
            // 说明
            Text("均衡器可以调节不同频段的音量，帮助您获得更好的听觉体验。")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 16)
        }
    }
    
    // MARK: - 预设选择器
    private var presetSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(EqualizerPreset.allCases, id: \.self) { preset in
                    PresetChip(
                        title: preset.rawValue,
                        isSelected: selectedPreset == preset
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPreset = preset
                            if preset != .custom {
                                customGains = preset.gains
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 均衡器滑块
    private var equalizerSliders: some View {
        SettingsCard {
            VStack(spacing: 16) {
                // 频段滑块
                HStack(spacing: isWideLayout ? 24 : 8) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 8) {
                            // 增益值
                            Text(String(format: "%+.0f", customGains[index]))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(width: 30)
                            
                            // 垂直滑块
                            VerticalSlider(value: $customGains[index], range: -12...12)
                                .frame(height: 150)
                                .onChange(of: customGains[index]) { _, _ in
                                    selectedPreset = .custom
                                }
                            
                            // 频率标签
                            Text(frequencies[index])
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 16)
                
                // dB 刻度说明
                HStack {
                    Text("-12 dB")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("0 dB")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("+12 dB")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
            }
            .padding(16)
        }
    }
    
    // MARK: - 重置按钮
    private var resetButton: some View {
        Button(action: {
            withAnimation {
                selectedPreset = .flat
                customGains = EqualizerPreset.flat.gains
            }
        }) {
            Text("重置为默认")
                .font(.system(size: 15))
                .foregroundColor(.purple)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(.systemBackground))
                .cornerRadius(10)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

// MARK: - 预设芯片
struct PresetChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.purple : Color(.systemGray5))
                )
        }
    }
}

// MARK: - 垂直滑块
struct VerticalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 轨道背景
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray4))
                    .frame(width: 6)
                
                // 进度条
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.purple)
                        .frame(width: 6, height: progressHeight(in: geometry))
                }
                
                // 滑块
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .scaleEffect(isDragging ? 1.1 : 1.0)
                    .offset(y: thumbOffset(in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                updateValue(with: gesture, in: geometry)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func progressHeight(in geometry: GeometryProxy) -> CGFloat {
        let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return max(0, geometry.size.height * CGFloat(normalized))
    }
    
    private func thumbOffset(in geometry: GeometryProxy) -> CGFloat {
        let normalized = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        let centerOffset = geometry.size.height / 2
        return centerOffset - (geometry.size.height * CGFloat(normalized))
    }
    
    private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let yPosition = gesture.location.y
        let height = geometry.size.height
        let normalized = 1.0 - Double(min(max(yPosition, 0), height) / height)
        value = range.lowerBound + (range.upperBound - range.lowerBound) * normalized
    }
}

#Preview {
    EqualizerView()
}
