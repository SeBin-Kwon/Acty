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
    var discountAmount: Int {
        return price.original - price.final
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
}
