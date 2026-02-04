//
//  AudioQualityView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct AudioQualityView: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown")
                .font(.system(size: 12))
                .opacity(0.6)
            
            Text("高清音质 | 无损 FLAC")
                .font(.system(size: 12))
                .opacity(0.6)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    AudioQualityView()
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}