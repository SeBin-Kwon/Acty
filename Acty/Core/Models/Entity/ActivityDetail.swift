//
//  ActivityDetail.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation

struct ActivityDetail: Hashable {
    let id: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: Geolocation
    let startDate: String
    let endDate: String
    let price: Price
    let tags: [String]
    let pointReward: Int
    let restrictions: Restrictions
    let description: String
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    let totalOrderCount: Int
    let schedule: [Schedule]
    let reservationList: [ReservationDate]
    let creator: Creator
    let createdAt: String
    let updatedAt: String
}

struct Restrictions: Hashable {
    let minHeight: Int
    let minAge: Int
    let maxParticipants: Int
}

struct Schedule: Hashable {
    let duration: String
    let description: String
}

struct ReservationDate: Hashable {
    let date: String
    let times: [ReservationTime]
}

struct ReservationTime: Hashable {
    let time: String
    let isReserved: Bool
}

struct Creator: Hashable {
    let userId: String
    let nickname: String
    let profileImage: String
    let introduction: String
}

extension ActivityDetail {
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
    
    // MARK: - 기존 메서드들 (환율 적용 버전으로 수정)
    var discountAmount: Int {
        return discountAmountInKRW
    }
    
    var discountRate: Int {
        guard price.original > 0 else { return 0 }
        return Int(((price.original - price.final) * 100) / price.original)
    }
    
    var hasDiscount: Bool {
        return price.original > price.final
    }
    
    var availableDates: [String] {
        return reservationList.map { $0.date }
    }
    
    var hasAvailableSlots: Bool {
        return reservationList.contains { date in
            date.times.contains { !$0.isReserved }
        }
    }
    
    /// 할인율 계산 (퍼센트)
    var discountPercentage: Int {
        guard price.original > 0 else { return 0 }
        return Int(((Double(price.original - price.final) / Double(price.original)) * 100).rounded())
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
}
