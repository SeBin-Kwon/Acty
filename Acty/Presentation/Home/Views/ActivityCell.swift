//
//  ActivityCell.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import SwiftUI
import NukeUI

struct ActivityCell: View {
    
    let activity: Activity
    
    var body: some View {
        
        VStack() {
            // 이미지 섹션
            ZStack {
                
                mediaContent
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.1),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(true)
                
                // 오버레이 요소들
                overlayContent
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(height: 188)
            
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(activity.tags.first ?? "")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.thinMaterial)
                    .opacity(0.5)
            )
            .overlay(
                Capsule()
                    .stroke(.white, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .offset(y: -25)
            .opacity(activity.tags.isEmpty ? 0 : 1)
            
            // 컨텐츠 섹션
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(activity.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image("Like_Fill")
                                .iconStyle(color: .rosy)
                            Text("\(activity.keepCount)개")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 4) {
                            Image("Point")
                                .iconStyle(color: .deepBlue)
                            Text("\(activity.pointReward)P")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // 설명 텍스트
                //                VStack(alignment: .leading, spacing: 2) {
                ////                    Text(description ?? "")
                ////                        .font(.caption)
                ////                        .foregroundColor(.secondary)
                //
                //                    Text("야적은 시들지만, 하늘을 향한 마음은 누구보다 단단한 세상 팀의 비상.")
                //                        .font(.caption)
                //                        .foregroundColor(.secondary)
                //                }
                
                // 가격
                HStack(alignment: .bottom, spacing: 8) {
                    // 원가 (취소선) + 할인율
                    
                    if activity.hasDiscount {
                        Text(activity.formattedOriginalPrice)
                            .font(.pretendard(.body1(.bold)))
                            .foregroundColor(.gray)
                            .strikethrough(true, color: .gray)
                    }
                    Text(activity.formattedFinalPrice)
                        .font(.pretendard(.body1(.bold)))
                        .fontWeight(.bold)
                    if activity.hasDiscount {
                        Text("\(activity.discountPercentage)%")
                            .font(.pretendard(.body1(.bold)))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 5)
            .offset(y: -20)
            .allowsHitTesting(true)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray30)
                .padding(.bottom, 25)
        }
    }
}

extension ActivityCell {
    @ViewBuilder
    private var mediaContent: some View {
        if let videoURL = activity.fullVideoURL() {
            // 영상이 있으면 영상 재생
            ActivityVideoView(
                videoURL: videoURL,
                activityId: activity.id
            )
        } else if let imageURL = activity.fullImageURL() {
            // 영상이 없으면 이미지 표시
            imageView(imageURL: imageURL)
        } else {
            // 미디어가 없으면 기본 플레이스홀더
            defaultPlaceholder
        }
    }
    
    private func imageView(imageURL: String) -> some View {
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
        .frame(height: 188)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .allowsHitTesting(false)
    }
    
    private var defaultPlaceholder: some View {
        Rectangle()
            .fill(LinearGradient(
                colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(height: 188)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.7))
                    Text("미디어 없음")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .allowsHitTesting(false)
    }
    
    private var overlayContent: some View {
        VStack {
            HStack {
                // 나라
                HStack(spacing: 4) {
                    Image("Location")
                        .iconStyle()
                    
                    
                    Text(activity.country)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.trailing, 4)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.25))
                .clipShape(Capsule())
                // 좋아요 버튼
                //                        Button {
                //                            print("좋아요 버튼")
                //                        } label: {
                //                            Image(systemName: activity.isKeep ? "heart.fill" : "heart")
                //                                .font(.system(size: 16))
                //                                .foregroundColor(.white)
                //                                .frame(width: 40, height: 40)
                //                        }
                //
                Spacer()
                
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer()
            
            HStack {
                Spacer()
                
                // 광고 버튼
                if activity.isAdvertisement {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image("Info")
                                .iconStyle()
                            
                            Text("광고")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Capsule())
                    }
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    ActivityCell(activity: Activity(
        id: "mock1",
        title: "한강 피크닉 패키지",
        country: "대한민국",
        category: "관광",
        thumbnails: ["/data/activities/8290926-sd_640_360_30fps_1750835811684.mp4", "/data/activities/niklas-ohlrogge-niamoh-de-tc2Cts4aXCw_1747149046143.jpg"],
        geolocation: Geolocation(longitude: 126.9356, latitude: 37.5219),
        price: Price(original: 50000, final: 35000),
        tags: ["인기", "할인"],
        pointReward: 350,
        isAdvertisement: true,
        isKeep: false,
        keepCount: 245
    ))
}
