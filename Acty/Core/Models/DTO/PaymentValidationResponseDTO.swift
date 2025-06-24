//
//  PaymentValidationResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/24/25.
//

import Foundation

struct PaymentValidationResponseDTO: Codable {
    let paymentId: String
    let orderItem: OrderItem
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case orderItem = "order_item"
        case createdAt, updatedAt
    }
    
    struct OrderItem: Codable {
        let orderId: String
        let orderCode: String
        let totalPrice: Int
        let reservationItemName: String
        let reservationItemTime: String
        let participantCount: Int
        let activity: Activity
        let paidAt: String
        let createdAt: String
        let updatedAt: String
        
        enum CodingKeys: String, CodingKey {
            case orderId = "order_id"
            case orderCode = "order_code"
            case totalPrice = "total_price"
            case reservationItemName = "reservation_item_name"
            case reservationItemTime = "reservation_item_time"
            case participantCount = "participant_count"
            case activity, paidAt, createdAt, updatedAt
        }
    }
    
    struct Activity: Codable {
        let id: String
        let title: String
        let country: String
        let category: String
        let thumbnails: [String]
        let geolocation: Geolocation
        let price: Price
        let tags: [String]
        let pointReward: Int
        
        enum CodingKeys: String, CodingKey {
            case id, title, country, category, thumbnails, geolocation, price, tags
            case pointReward = "point_reward"
        }
        
        struct Geolocation: Codable {
            let longitude: Double
            let latitude: Double
        }
        
        struct Price: Codable {
            let original: Int
            let final: Int
        }
    }
}
