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

struct Activity: Identifiable {
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

struct Geolocation {
    let longitude: Double
    let latitude: Double
}

struct Price {
    let original: Int
    let final: Int
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
        return thumbnails.first
    }
    
    /// 완전한 이미지 URL 생성 (BASE_URL과 결합)
    func fullImageURL(baseURL: String = BASE_URL) -> String? {
        guard let thumbnail = mainThumbnail else { return nil }
        return baseURL + thumbnail
    }
    
    /// 할인 금액 계산
    var discountAmount: Int {
        return price.original - price.final
    }
    
    /// 가격 포맷팅 (예: "120원")
    var formattedFinalPrice: String {
        return "\(price.final)원"
    }
    
    /// 원가 포맷팅 (취소선용)
    var formattedOriginalPrice: String {
        return "\(price.original)원"
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
