//
//  ActivityDetailInfoView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/12/25.
//

import SwiftUI

struct ActivityDetailInfoView: View {
    let activityDetail: ActivityDetail
    
    // 할인율 계산
    private var discountPercentage: Int {
        let originalPrice = Double(activityDetail.price.original)
        let finalPrice = Double(activityDetail.price.final)
        let discount = ((originalPrice - finalPrice) / originalPrice) * 100
        return Int(discount.rounded())
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 제약사항 정보
            restrictionsSection
            
            // 가격 정보
            priceSection
            
            // 액티비티 커리큘럼
            curriculumSection
            
            // 위치 정보
            locationSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - View Components
extension ActivityDetailInfoView {
    
    private var restrictionsSection: some View {
        VStack(spacing: 16) {
            HStack {
                restrictionItem(
                    icon: "Age",
                    title: "연령제한",
                    value: "\(activityDetail.restrictions.minAge)세",
                    color: .blue
                )
                
                Spacer()
                
                restrictionItem(
                    icon: "Hand",
                    title: "신장제한",
                    value: "\(activityDetail.restrictions.minHeight)cm",
                    color: .green
                )
                
                Spacer()
                
                restrictionItem(
                    icon: "People",
                    title: "최대참가인원",
                    value: "\(activityDetail.restrictions.maxParticipants)명",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray30, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func restrictionItem(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(icon)
                .iconStyle(width: 32, height: 32, color: .gray60)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.pretendard(.caption2(.medium)))
                    .foregroundColor(.gray45)
                
                Text(value)
                    .font(.pretendard(.body3(.bold)))
                    .foregroundColor(.gray75)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("판매가")
                    .font(.paperLogy(.body1))
                    .foregroundColor(.gray90)
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                // 원가 (취소선)
                Text("\(activityDetail.price.original.formatted())원")
                    .font(.paperLogy(.body1))
                    .foregroundColor(.gray45)
                    .strikethrough()
                
                // 할인가
                Text("\(activityDetail.price.final.formatted())원")
                    .font(.paperLogy(.body1))
                    .foregroundColor(.gray75)
                
                // 할인율
                Text("\(discountPercentage)%")
                    .font(.paperLogy(.body1))
                    .foregroundColor(.deepBlue)
                
                Spacer()
            }
        }
    }
    
    private var curriculumSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("커리큘럼")
                .font(.paperLogy(.body1))
                .foregroundColor(.gray90)
            
            VStack(alignment: .leading) {
                ForEach(Array(activityDetail.schedule.enumerated()), id: \.offset) { index, schedule in
                    curriculumItem(
                        duration: schedule.duration,
                        description: schedule.description,
                        isLast: index == activityDetail.schedule.count - 1
                    )
                }
            }
            .padding(.leading, 8)
        }
    }
    
    private func curriculumItem(duration: String, description: String, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 2) {
                Circle()
                    .fill(.accent)
                    .frame(width: 8, height: 8)
                    .padding(.top, 3)
                if !isLast {
                    Rectangle()
                        .fill(.accent)
                        .frame(width: 1, height: 40)
                        .offset(y: 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("용프라우, 스위스")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                // 지도 썸네일
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "map")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("용프라우, 스위스")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("위도: \(String(format: "%.6f", activityDetail.geolocation.latitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("경도: \(String(format: "%.6f", activityDetail.geolocation.longitude))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview
struct ActivityDetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ActivityDetailInfoView(activityDetail: sampleActivityDetail)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    static let sampleActivityDetail = ActivityDetail(
        id: "6843f67c5c57725aaa782521",
        title: "세상 패러글라이딩 2기",
        country: "스위스",
        category: "익스트림",
        thumbnails: [],
        geolocation: Geolocation(longitude: 127.049914, latitude: 37.654215),
        startDate: "2025-07-01",
        endDate: "2025-09-30",
        price: Price(original: 605000, final: 520000),
        tags: ["New 오픈특가", "인기급상승", "얼리버드"],
        pointReward: 5200,
        restrictions: Restrictions(minHeight: 150, minAge: 16, maxParticipants: 8),
        description: "두려움을 넘고, 하늘을 향한 두 번째 도전이 시작됩니다.",
        isAdvertisement: false,
        isKeep: true,
        keepCount: 35,
        totalOrderCount: 127,
        schedule: [
            Schedule(duration: "시작 - 10분", description: "안전 교육 및 장비 착용 (우천 시 취소될 수 있습니다)"),
            Schedule(duration: "10분 - 30분", description: "기본 비행 자세 및 착륙 연습"),
            Schedule(duration: "30분 - 1시간 30분", description: "인스트럭터와 함께하는 탠덤 패러글라이딩 체험"),
            Schedule(duration: "1시간 30분 - 2시간", description: "착륙 후 기념사진 촬영 및 소감 나누기")
        ],
        reservationList: [],
        creator: Creator(userId: "6826cd67e5c54c8fdd914662", nickname: "스카이마스터", profileImage: "", introduction: "10년 경력의 패러글라이딩 전문가입니다."),
        createdAt: "2025-06-07T08:21:16.119Z",
        updatedAt: "2025-06-07T08:21:16.119Z"
    )
}
