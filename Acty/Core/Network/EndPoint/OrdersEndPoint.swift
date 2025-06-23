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
    case paymentValidation(String)
    case paymentHistory(String)
    
    var path: String {
        switch self {
        case .orders, .ordersHistory: baseURL + "/orders"
        case .paymentValidation: baseURL + "/payments/validation"
        case .paymentHistory(let order): baseURL + "/payments/\(order)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .orders, .paymentValidation: .post
        case .ordersHistory, .paymentHistory: .get
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
        case .paymentValidation(let order):
            return ["imp_uid": order]
        case .paymentHistory(let order):
            return ["order_code": order]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .orders, .paymentValidation: JSONEncoding.default
        case .ordersHistory, .paymentHistory: URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
