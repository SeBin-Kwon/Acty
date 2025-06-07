//
//  EndPoint.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import Foundation
import Alamofire

enum AuthEndPoint: EndPoint {
    
    case signUp(SignUpRequestDTO)
    case emailSignIn(EmailSignInRequestDTO)
    case appleSignIn(AppleSignInRequestDTO)
    case kakaoSignIn(KakaoSignInRequestDTO)
    case refreshToken(String)
    case myProfileGet
    
    var path: String {
        switch self {
        case .signUp: baseURL + "users/join"
        case .emailSignIn: baseURL + "users/login"
        case .appleSignIn: baseURL + "users/login/apple"
        case .kakaoSignIn: baseURL + "users/login/kakao"
        case .refreshToken: baseURL + "auth/refresh"
        case .myProfileGet: baseURL + "users/me/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken: .post
        case .myProfileGet: .get
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
        case .myProfileGet: return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken:  JSONEncoding.default
        case .myProfileGet: URLEncoding(destination: .queryString)
        }
       
    }
    
    var isAuthRequired: Bool {
        switch self {
        case .signUp, .emailSignIn, .appleSignIn, .kakaoSignIn, .refreshToken: false
        case .myProfileGet: true
        }
    }
}

