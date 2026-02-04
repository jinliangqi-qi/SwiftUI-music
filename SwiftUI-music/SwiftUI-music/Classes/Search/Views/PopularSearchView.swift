//
//  PopularSearchView.swift
//  SwiftUI-music
//
//  Created by 金亮大神on 2025/3/12.
//

import SwiftUI

struct PopularSearchView: View {
    // 热门搜索关键词
    private let popularKeywords = [
        "周杰伦", "陈奕迅", "林俊杰", "Taylor Swift",
        "华语流行", "热门说唱", "抖音热歌", "独立民谣", "粤语经典"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text("热门搜索")
                .font(.system(size: 18, weight: .bold))
            
            // 标签流式布局
            FlowLayout(spacing: 8) {
                ForEach(popularKeywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.system(size: 14))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
            }
        }
    }
}

// 流式布局容器
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 10) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        let rows = computeRows(containerWidth: containerWidth, subviews: subviews)
        
        for row in rows {
            height += row.maxY - row.minY
        }
        
        // 添加行间距
        if rows.count > 1 {
            height += spacing * CGFloat(rows.count - 1)
        }
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(containerWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            let rowHeight = row.maxY - row.minY
            var x = bounds.minX
            
            for i in row.startIndex..<row.endIndex {
                let subview = subviews[i]
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: subviewSize.width, height: subviewSize.height))
                
                x += subviewSize.width + spacing
            }
            
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(containerWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row(startIndex: 0, endIndex: 0, minY: 0, maxY: 0)
        var x: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if x + subviewSize.width > containerWidth && currentRow.startIndex < index {
                // 当前行已满，创建新行
                currentRow.endIndex = index
                rows.append(currentRow)
                
                // 开始新行
                currentRow = Row(startIndex: index, endIndex: 0, minY: currentRow.maxY + spacing, maxY: currentRow.maxY + spacing + subviewSize.height)
                x = subviewSize.width + spacing
            } else {
                // 继续当前行
                x += subviewSize.width + spacing
                currentRow.maxY = max(currentRow.maxY, currentRow.minY + subviewSize.height)
            }
        }
        
        // 添加最后一行
        if currentRow.startIndex < subviews.count {
            currentRow.endIndex = subviews.count
            rows.append(currentRow)
        }
        
        return rows
    }
    
    struct Row {
        var startIndex: Int
        var endIndex: Int
        var minY: CGFloat
        var maxY: CGFloat
    }
}

#Preview {
    PopularSearchView()
        .padding()
}
