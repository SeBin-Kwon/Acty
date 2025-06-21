//
//  OrdersResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/18/25.
//

import Foundation

struct OrdersResponseDTO: Decodable {
    let id: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt, updatedAt
    }
}
