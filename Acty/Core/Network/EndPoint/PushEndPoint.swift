//
//  PushEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 7/22/25.
//

import Foundation
import Alamofire

enum PushEndPoint: EndPoint {
    case push(PushRequestDTO)
    
    var path: String {
        switch self {
        case .push: baseURL + "/notifications/push/group"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .push: .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .push(let request): return [
            "user_ids": request.userIds,
            "title": request.title,
            "subtitle": request.subtitle,
            "body": request.body
        ]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .push:
            return JSONEncoding.default
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
