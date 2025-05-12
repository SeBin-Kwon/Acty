//
//  EndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import Foundation
import Alamofire

enum EndPoint {
    case signUp(SignUpRequest)
    
    var baseURL: String {
        Sesac.baseURL
    }
    
    var endPoint: String {
        switch self {
        case .signUp: baseURL + "users/join"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signUp: .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .signUp(let request):
            ["email": request.email,
             "password": request.password,
             "nick": request.nick,
             "phoneNum": request.phoneNum,
             "introduction": request.introduction,
             "deviceToken": request.deviceToken]
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .signUp:
            ["Content-Type": "application/json", "SeSACKey": Sesac.key]

        }
    }
    
//    var error: Error.Type {
//        switch self {
//        }
//    }
}

struct SignUpRequest {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String = ""
    let introduction: String = ""
    let deviceToken: String = ""
}
