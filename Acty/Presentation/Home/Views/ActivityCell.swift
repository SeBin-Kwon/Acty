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
                
                // 오버레이 요소들
                VStack {
                    HStack {
                        // 좋아요 버튼
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        // 스위스 인터라켄 태그
                        HStack(spacing: 4) {
                            Text("✈️")
                            Text("스위스 인터라켄")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // 광고 버튼
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 12))
                                Text("광고")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(height: 188)
            
            HStack(spacing: 6) {
                // 반짝이는 별 아이콘
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                // NEW 텍스트
                Text("NEW")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                // 액티비티 오픈 텍스트
                Text("액티비티 오픈!")
                    .font(.system(size: 14, weight: .medium))
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
            
            // 컨텐츠 섹션
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(activity.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                                .font(.caption)
                            Text("\(activity.keepCount)개")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(activity.pointReward)개")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // 설명 텍스트
                VStack(alignment: .leading, spacing: 2) {
                    Text("두려움을 넘고, 하늘을 향한 두 번째 도전이 시작됩니다.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("야적은 시들지만, 하늘을 향한 마음은 누구보다 단단한 세상 팀의 비상.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 가격
                HStack(alignment: .bottom) {
                    
                    // 가격 정보
                    HStack(spacing: 2) {
                        Text(activity.formattedFinalPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("\(activity.discountPercentage)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 16)
            .offset(y: -10)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray30)
                .padding(.bottom, 20)
        }
    }
}

#Preview {
    ActivityCell(activity: Activity(
        id: "mock1",
        title: "한강 피크닉 패키지",
        country: "대한민국",
        category: "관광",
        thumbnails: ["/data/activities/6842398-sd_640_360_30fps_1747149175575.mp4", "/data/activities/niklas-ohlrogge-niamoh-de-tc2Cts4aXCw_1747149046143.jpg"],
        geolocation: Geolocation(longitude: 126.9356, latitude: 37.5219),
        price: Price(original: 50000, final: 35000),
        tags: ["인기", "할인"],
        pointReward: 350,
        isAdvertisement: false,
        isKeep: false,
        keepCount: 245
    ))
}
