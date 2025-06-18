//
//  OrdersResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/18/25.
//

import Foundation

struct OrdersResponseDTO {
    let id: String
    let orderCode: String
    let totalPrice: String
    let createdAt: Int
    let updatedAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt, updatedAt
    }
}
