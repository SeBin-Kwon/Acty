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
    case newActivity(ActivityRequestDTO)
    
    var path: String {
        switch self {
        case .activity: baseURL + "/activities"
        case .newActivity: baseURL + "/activities/new"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .activity, .newActivity: .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .activity(let activity):
            return ["country": activity.country,
                    "category": activity.category,
                    "limit": activity.limit,
                    "next": activity.next]
        case .newActivity(let activity):
            return ["country": activity.country,
                    "category": activity.category]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .activity, .newActivity:
            return URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
