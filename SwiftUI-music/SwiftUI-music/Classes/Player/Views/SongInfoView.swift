//
//  SongInfoView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct SongInfoView: View {
    let title: String
    let artist: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text(artist)
                .font(.system(size: 16))
                .opacity(0.8)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    SongInfoView(title: "夜曲", artist: "周杰伦")
        .padding()
        .background(Color.purple.opacity(0.5))
        .foregroundColor(.white)
}