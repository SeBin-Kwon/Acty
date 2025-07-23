//
//  PushRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/23/25.
//

import Foundation

struct PushRequestDTO: Codable {
    let userIds: [String]
    let title: String
    let subtitle: String
    let body: String
    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
        case title, subtitle, body
    }
}
