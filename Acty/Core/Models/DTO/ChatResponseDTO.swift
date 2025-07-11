//
//  ChatResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/7/25.
//

import Foundation

struct ChatMessagesResponseDTO: Codable {
    let data: [ChatResponseDTO]
}

struct ChatResponseDTO: Codable, Equatable {
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

struct SenderDTO: Codable, Equatable {
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

extension ChatResponseDTO {
    /// 메시지 시간을 Date로 변환
    var createdAtDate: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt) ?? Date()
    }
    
    /// 표시용 시간 문자열 (HH:mm)
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: createdAtDate)
    }

}

extension SenderDTO {
    func fullImageURL(baseURL: String = BASE_URL) -> String? {
        guard let profileImage = profileImage else { return nil }
        print(baseURL + profileImage)
        return baseURL + profileImage
    }
}
