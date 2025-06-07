//
//  ActivityDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

struct ActivityListResponseDTO: Decodable {
    let data: [ActivityResponseDTO]
    let nextCursor: String?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct ActivityResponseDTO: Decodable, Identifiable {
    let id: String?
    let title: String?
    let country: String?
    let category: String?
    let thumbnails: [String]?
    let geolocation: GeolocationDTO?
    let price: PriceDTO?
    let tags: [String]?
    let pointReward: Int?
    let isAdvertisement: Bool?
    let isKeep: Bool?
    let keepCount: Int?
    
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

extension ActivityResponseDTO {
    func toEntity() -> Activity {
        return Activity(
            id: id ?? "",
            title: title ?? "",
            country: country ?? "",
            category: category ?? "",
            thumbnails: thumbnails ?? [],
            geolocation: Geolocation(
                longitude: geolocation?.longitude ?? 0,
                latitude: geolocation?.latitude ?? 0
            ),
            price: Price(
                original: price?.original ?? 0,
                final: price?.final ?? 0
            ),
            tags: tags ?? [],
            pointReward: pointReward ?? 0,
            isAdvertisement: isAdvertisement ?? false,
            isKeep: isKeep ?? false,
            keepCount: keepCount ?? 0
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
