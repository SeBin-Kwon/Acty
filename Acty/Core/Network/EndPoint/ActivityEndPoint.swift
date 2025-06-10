//
//  ActivityEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import Foundation
import Alamofire

enum ActivityEndPoint: EndPoint {
    case activity(ActivityRequestDTO)
    
    var path: String {
        switch self {
        case .activity: baseURL + "/activities"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .activity: .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .activity(let activity):
            return ["country": activity.country,
                    "category": activity.category,
                    "limit": activity.limit,
                    "next": activity.next]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .activity:
            return URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
