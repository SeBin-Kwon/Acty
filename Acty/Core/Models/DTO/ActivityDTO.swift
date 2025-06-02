//
//  ActivityDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

struct ActivityListResponseDTO: Decodable {
    let data: [ActivityDTO]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct ActivityDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: GeolocationDTO
    let price: PriceDTO
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "activity_id"
        case title, country, category, thumbnails, geolocation, price, tags
        case pointReward = "point_reward"
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
    }
}

struct GeolocationDTO: Decodable {
    let longitude: Double
    let latitude: Double
}

struct PriceDTO: Decodable {
    let original: Int
    let final: Int
}

extension ActivityDTO {
    func toEntity() -> Activity {
        return Activity(
            id: id,
            title: title,
            country: country,
            category: category,
            thumbnails: thumbnails,
            geolocation: Geolocation(
                longitude: geolocation.longitude,
                latitude: geolocation.latitude
            ),
            price: Price(
                original: price.original,
                final: price.final
            ),
            tags: tags,
            pointReward: pointReward,
            isAdvertisement: isAdvertisement,
            isKeep: isKeep,
            keepCount: keepCount
        )
    }
}

extension ActivityListResponseDTO {
    func toEntity() -> ActivityList {
        return ActivityList(
            activities: data.map { $0.toEntity() },
            nextCursor: nextCursor
        )
    }
}
