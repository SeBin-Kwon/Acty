//
//  UserDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 5/16/25.
//

import Foundation

struct UserDTO: Codable {
    let id: Int
    let email: String
    let nickname: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, nickname, profileImage, accessToken, refreshToken
    }
}
