//
//  ActivityBannerView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/9/25.
//

import SwiftUI
import NukeUI

struct ActivityBannerView: View {
    let activity: Activity
    
    var body: some View {
        ZStack {
            LazyImage(url: URL(string: activity.fullImageURL() ?? "")) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if state.error != nil {
                    // 에러 시 기본 이미지
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                } else {
                    // 로딩 중
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
            }
            .frame(width: 300, height: 300)
            
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 콘텐츠
            VStack(alignment: .leading, spacing: 12) {
                // 상단 카테고리 태그
                HStack {
                    Text(activity.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .background(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                // 하단 콘텐츠
                VStack(alignment: .leading, spacing: 8) {
                    // 제목
                    Text(activity.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // 가격
                    HStack {
                        Image(systemName: "wonsign.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        Text(String(activity.formattedFinalPrice))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // 설명
//                    Text(activity.description)
//                        .font(.body)
//                        .foregroundColor(.white.opacity(0.9))
//                        .lineLimit(3)
//                        .multilineTextAlignment(.leading)
                    
                    // 위치 (있는 경우)
//                    if let location = activity.location {
//                        HStack {
//                            Image(systemName: "location.fill")
//                                .foregroundColor(.white.opacity(0.8))
//                                .font(.caption)
//                            Text(location)
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
                }
            }
            .padding(20)
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

//#Preview {
//    ActivityBannerView()
//}
