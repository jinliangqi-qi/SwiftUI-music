//
//  AlbumCoverView.swift
//  SwiftUI-music
//
//  Created by Trae AI on 2025/3/12.
//

import SwiftUI

struct AlbumCoverView: View {
    let imageUrl: String
    
    var body: some View {
        VStack {
            CachedImageView(urlString: imageUrl)
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.vertical, 20)
        }
    }
}

#Preview {
    AlbumCoverView(imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bXVzaWN8ZW58MHx8MHx8fDA%3D")
        .padding()
        .background(Color.purple.opacity(0.5))
}