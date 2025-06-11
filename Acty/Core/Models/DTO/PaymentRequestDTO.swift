//
//  PaymentRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation

struct PaymentRequestDTO {
    let id: String
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let totalPrice: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "activity_id"
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case participantCount = "participant_count"
        case totalPrice = "total_price"
    }
}
