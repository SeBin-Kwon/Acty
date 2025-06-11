//
//  ActivityDetailResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation

struct ActivityDetailResponseDTO: Decodable {
    let activityId: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: GeolocationDTO
    let startDate: String
    let endDate: String
    let price: PriceDTO
    let tags: [String]
    let pointReward: Int
    let restrictions: RestrictionsDTO
    let description: String
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    let totalOrderCount: Int
    let schedule: [ScheduleDTO]
    let reservationList: [ReservationDateDTO]
    let creator: CreatorDTO
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case title, country, category, thumbnails, geolocation
        case startDate = "start_date"
        case endDate = "end_date"
        case price, tags
        case pointReward = "point_reward"
        case restrictions, description
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
        case totalOrderCount = "total_order_count"
        case schedule
        case reservationList = "reservation_list"
        case creator, createdAt, updatedAt
    }
}

struct RestrictionsDTO: Decodable {
    let minHeight: Int
    let minAge: Int
    let maxParticipants: Int
    
    enum CodingKeys: String, CodingKey {
        case minHeight = "min_height"
        case minAge = "min_age"
        case maxParticipants = "max_participants"
    }
}

struct ScheduleDTO: Decodable {
    let duration: String
    let description: String
}

struct ReservationDateDTO: Decodable {
    let itemName: String
    let times: [ReservationTimeDTO]
    
    enum CodingKeys: String, CodingKey {
        case itemName = "item_name"
        case times
    }
}

struct ReservationTimeDTO: Decodable {
    let time: String
    let isReserved: Bool
    
    enum CodingKeys: String, CodingKey {
        case time
        case isReserved = "is_reserved"
    }
}

struct CreatorDTO: Decodable {
    let userId: String
    let nick: String
    let profileImage: String?
    let introduction: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, profileImage, introduction
    }
}

extension ActivityDetailResponseDTO {
    func toEntity() -> ActivityDetail {
        return ActivityDetail(
            id: activityId,
            title: title,
            country: country,
            category: category,
            thumbnails: thumbnails,
            geolocation: Geolocation(
                longitude: geolocation.longitude,
                latitude: geolocation.latitude
            ),
            startDate: startDate,
            endDate: endDate,
            price: Price(
                original: price.original,
                final: price.final
            ),
            tags: tags,
            pointReward: pointReward,
            restrictions: restrictions.toEntity(),
            description: description,
            isAdvertisement: isAdvertisement,
            isKeep: isKeep,
            keepCount: keepCount,
            totalOrderCount: totalOrderCount,
            schedule: schedule.map { $0.toEntity() },
            reservationList: reservationList.map { $0.toEntity() },
            creator: creator.toEntity(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension RestrictionsDTO {
    func toEntity() -> Restrictions {
        return Restrictions(
            minHeight: minHeight,
            minAge: minAge,
            maxParticipants: maxParticipants
        )
    }
}

extension ScheduleDTO {
    func toEntity() -> Schedule {
        return Schedule(
            duration: duration,
            description: description
        )
    }
}

extension ReservationDateDTO {
    func toEntity() -> ReservationDate {
        return ReservationDate(
            date: itemName,
            times: times.map { $0.toEntity() }
        )
    }
}

extension ReservationTimeDTO {
    func toEntity() -> ReservationTime {
        return ReservationTime(
            time: time,
            isReserved: isReserved
        )
    }
}

extension CreatorDTO {
    func toEntity() -> Creator {
        return Creator(
            userId: userId,
            nickname: nick,
            profileImage: profileImage ?? "",
            introduction: introduction
        )
    }
}
