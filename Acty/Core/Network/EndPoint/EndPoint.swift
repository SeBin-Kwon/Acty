//
//  EndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation
import Alamofire

protocol EndPoint {
    var baseURL: String { get }
    var endPoint: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
    var encoding: ParameterEncoding { get }
//    var decoder: JSONDecoder { get }
}

extension EndPoint {
    var baseURL: String {
        return "Bundle.main.baseURL"
    }
}
