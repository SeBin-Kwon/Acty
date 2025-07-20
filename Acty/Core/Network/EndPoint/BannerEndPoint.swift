//
//  BannerEndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 7/20/25.
//

import Foundation
import Alamofire

enum BannerEndPoint: EndPoint {
    case getMainBanners
    
    var path: String {
        switch self {
        case .getMainBanners:
            return baseURL + "/banners/main"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMainBanners:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getMainBanners:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .getMainBanners:
            return URLEncoding(destination: .queryString)
        }
    }
    
    var isAuthRequired: Bool {
        switch self {
        case .getMainBanners:
            return true
        }
    }
}
