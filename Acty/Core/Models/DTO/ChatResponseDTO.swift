//
//  ChatResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/7/25.
//

import Foundation

struct ChatResponseDTO: Codable {
    let chatId: String
    let roomId: String
    let content: String?
    let createdAt: String
    let updatedAt: String
    let sender: SenderDTO
    let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}

struct SenderDTO: Codable {
    let userId: String
    let nick: String
    let name: String?
    let profileImage: String?
    let introduction: String?
    let hashTags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, name, profileImage, introduction, hashTags
    }
}
