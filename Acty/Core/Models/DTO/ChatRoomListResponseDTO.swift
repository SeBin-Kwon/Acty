//
//  ChatRoomListResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/2/25.
//

import Foundation

struct ChatRoomListResponseDTO: Codable {
    let data: [ChatRoomResponseDTO]
}

struct ChatRoomResponseDTO: Codable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [ParticipantDTO]
    let lastChat: LastChatDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

struct ParticipantDTO: Codable {
    let userId: String
    let nick: String
    let profileImage: String?
    let introduction: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick, profileImage, introduction
    }
}

struct LastChatDTO: Codable {
    let chatId: String
    let roomId: String
    let content: String?
    let createdAt: String
    let updatedAt: String
    let sender: ParticipantDTO
    let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content, createdAt, updatedAt, sender, files
    }
}
