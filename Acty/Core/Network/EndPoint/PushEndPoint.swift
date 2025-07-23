//
//  PushEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 7/22/25.
//

import Foundation
import Alamofire

enum PushEndPoint: EndPoint {
    case push
    
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
        case .push: nil
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
