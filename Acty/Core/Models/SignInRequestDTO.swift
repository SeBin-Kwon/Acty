//
//  SignInRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 5/16/25.
//

import Foundation

struct EmailSignInRequestDTO {
    let email: String
    let password: String
    let deviceToken: String?
}

struct AppleSignInRequestDTO {
    let idToken: String
    let deviceToken: String?
    let nick: String?
}

struct KakaoSignInRequestDTO {
    let oauthToken: String
    let deviceToken: String?
}
