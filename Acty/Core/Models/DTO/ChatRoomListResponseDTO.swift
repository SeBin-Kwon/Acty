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
    let participants: [SenderDTO]
    let lastChat: ChatResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}
