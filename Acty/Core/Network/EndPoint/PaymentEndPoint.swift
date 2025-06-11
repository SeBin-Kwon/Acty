//
//  PaymentEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation
import Alamofire

enum PaymentEndPoint: EndPoint {
    case orders(PaymentRequestDTO)
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
            return ["activity_id": activity.country,
                    "reservation_item_name": activity.category,
                    "reservation_item_time": activity.limit,
                    "participant_count": activity.next]
        case .ordersHistory: nil
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
