//
//  EndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation
import Alamofire

protocol Endpoint: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
    var encoder: ParameterEncoder? { get }
    var decoder: JSONDecoder { get }
}

extension Endpoint {
    var baseURL: String {
        return "Bundle.main.baseURL"
    }
}
