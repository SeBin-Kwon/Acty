//
//  OrdersEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation
import Alamofire

enum OrdersEndPoint: EndPoint {
    case orders(OrdersRequestDTO)
    case ordersHistory
    
    var path: String {
        switch self {
        case .orders, .ordersHistory: baseURL + "/orders"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .orders: .post
        case .ordersHistory: .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .orders(let order):
            return ["activity_id": order.id,
                    "reservation_item_name": order.reservationItemName,
                    "reservation_item_time": order.reservationItemTime,
                    "participant_count": order.participantCount,
                    "total_price": order.totalPrice]
        case .ordersHistory:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .orders: JSONEncoding.default
        case .ordersHistory: URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
