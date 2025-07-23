//
//  BannerView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/23/25.
//

import SwiftUI
import NukeUI

struct BannerView: View {
    let banner: Banner
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            LazyImage(url: URL(string: banner.fullImageURL)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if state.error != nil {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay(
                            Text(banner.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
            }
            .frame(height: 100)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}
