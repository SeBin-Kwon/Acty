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
    case activityDetail(_ id: String)
    
    var path: String {
        switch self {
        case .activity: baseURL + "/activities"
        case .newActivity: baseURL + "/activities/new"
        case .activityDetail(let id): baseURL + "/activities/" + id
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .activity, .newActivity, .activityDetail: .get
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
        case .activityDetail(let id):
            return ["activity_id": id]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .activity, .newActivity, .activityDetail:
            return URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        true
    }
}
