//
//  EndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation
import Alamofire

protocol EndPoint: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
    var encoding: ParameterEncoding { get }
    var isAuthRequired: Bool { get }
}

extension EndPoint {
    var baseURL: String {
        BASE_URL
    }
    
    var headers: HTTPHeaders {
        ["Content-Type": "application/json", "SeSACKey": API_KEY]
    }
}
