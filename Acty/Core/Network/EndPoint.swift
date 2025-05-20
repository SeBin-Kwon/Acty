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
    case emailSignIn(EmailSignInRequestDTO)
    case appleSignIn(AppleSignInRequestDTO)
    case kakaoSignIn(KakaoSignInRequestDTO)
    case refreshToken(String)
    
    var baseURL: String {
        BASE_URL
    }
    
    var endPoint: String {
        switch self {
        case .signUp: baseURL + "users/join"
        case .emailSignIn: baseURL + "users/login"
        case .appleSignIn: baseURL + "users/login/apple"
        case .kakaoSignIn: baseURL + "users/login/kakao"
        case .refreshToken: baseURL + "auth/refresh"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken: .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .signUp(let request):
            return ["email": request.email,
                   "password": request.password,
                   "nick": request.nick,
                   "phoneNum": request.phoneNum,
                   "introduction": request.introduction,
                   "deviceToken": request.deviceToken]
        case .emailSignIn(let dto):
            return ["email": dto.email,
                   "password": dto.password,
                   "deviceToken": dto.deviceToken ?? ""]
        case .appleSignIn(let dto):
            return ["idToken": dto.idToken,
                   "deviceToken": dto.deviceToken ?? "",
                   "nick": dto.nick ?? ""]
        case .kakaoSignIn(let dto):
            return ["oauthToken": dto.oauthToken,
                   "deviceToken": dto.deviceToken ?? ""]
        case .refreshToken(let token):
            return ["refreshToken": token]
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken:
            return ["Content-Type": "application/json", "SeSACKey": API_KEY]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken:
            return JSONEncoding.default
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken: false
        }
    }
}

struct SignUpRequest {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String = ""
    let introduction: String = ""
    let deviceToken: String = ""
}
