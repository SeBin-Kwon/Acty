//
//  Activity.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

struct ActivityList {
    let activities: [Activity]
    let nextCursor: String?
}

struct Activity: Identifiable, Hashable {
    let id: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: Geolocation
    let price: Price
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    var isKeep: Bool
    let keepCount: Int
}

struct Geolocation: Hashable {
    let longitude: Double
    let latitude: Double
}

struct Price: Hashable {
    let original: Int
    let final: Int
}

extension Activity {
    // MARK: - 환율 설정
    private static let exchangeRate: Double = 1380.0
    
    // MARK: - 원화 변환된 가격
    /// 원가를 원화로 변환
    var originalPriceInKRW: Int {
        return Int(Double(price.original) * Self.exchangeRate)
    }
    
    /// 할인가를 원화로 변환
    var finalPriceInKRW: Int {
        return Int(Double(price.final) * Self.exchangeRate)
    }
    
    /// 할인 금액 계산 (원화)
    var discountAmountInKRW: Int {
        return originalPriceInKRW - finalPriceInKRW
    }
    
    // MARK: - 포맷팅된 가격 문자열
    /// 할인가 포맷팅 (예: "162,000원")
    var formattedFinalPrice: String {
        return finalPriceInKRW.formattedWithComma + "원"
    }
    
    /// 원가 포맷팅 (취소선용) (예: "202,500원")
    var formattedOriginalPrice: String {
        return originalPriceInKRW.formattedWithComma + "원"
    }
    
    /// 할인 금액 포맷팅 (예: "40,500원 할인")
    var formattedDiscountAmount: String {
        return discountAmountInKRW.formattedWithComma + "원 할인"
    }
}

extension Activity {
    /// 할인율 계산 (퍼센트)
    var discountPercentage: Int {
        guard price.original > 0 else { return 0 }
        return Int(((Double(price.original - price.final) / Double(price.original)) * 100).rounded())
    }
    
    /// 할인이 있는지 확인
    var hasDiscount: Bool {
        return price.original > price.final
    }
    
    /// 메인 썸네일 이미지 URL (첫 번째 이미지)
    var mainThumbnail: String? {
        let images = thumbnails.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".jpeg") || $0.hasSuffix(".png") }
        return images.first
    }
    
    /// 완전한 이미지 URL 생성 (BASE_URL과 결합)
    func fullImageURL(baseURL: String = BASE_URL) -> String? {
        guard let thumbnail = mainThumbnail else { return nil }
        print(baseURL + thumbnail)
        return baseURL + thumbnail
    }
    
    var mainVideoThumbnail: String? {
        let videos = thumbnails.filter {
            let lowercased = $0.lowercased()
            return lowercased.hasSuffix(".mp4") ||
                   lowercased.hasSuffix(".mov") ||
                   lowercased.hasSuffix(".avi")
        }
        return videos.first
    }
    
    func fullVideoURL(baseURL: String = BASE_URL) -> String? {
        guard let videoThumbnail = mainVideoThumbnail else { return nil }
        return baseURL + videoThumbnail
    }
}

extension Activity {
    static let preview = Activity(
        id: "60f7e1b3d4f3e0a8d4c3f4b0",
        title: "신나는 서울 야경 투어",
        country: "대한민국",
        category: "투어",
        thumbnails: ["/data/activities/seoul_night_1_1746814739531.jpg"],
        geolocation: Geolocation(longitude: 127.0016985, latitude: 37.5642135),
        price: Price(original: 150, final: 120),
        tags: ["New 오픈특가"],
        pointReward: 100,
        isAdvertisement: false,
        isKeep: true,
        keepCount: 120
    )
    
    static let previewList = Array(repeating: Activity.preview, count: 5)
}

extension ActivityList {
    static let preview = ActivityList(
        activities: Activity.previewList,
        nextCursor: "670bfd66539a670e42b2a4e9"
    )
}
