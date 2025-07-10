//
//  ChatEntity.swift
//  Acty
//
//  Created by Sebin Kwon on 7/3/25.
//

import Foundation
import CoreData

extension ChatMessageEntity {
    
    // Files 배열 처리
    var files: [String] {
        get {
            guard let data = filesData,
                  let files = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return files
        }
        set {
            filesData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // DTO로 변환
    func toDTO() -> ChatResponseDTO {
        let sender = SenderDTO(
            userId: senderId ?? "",
            nick: senderNick ?? "",
            name: senderName,
            profileImage: senderProfileImage,
            introduction: nil,
            hashTags: nil
        )
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return ChatResponseDTO(
            chatId: chatId ?? "",
            roomId: roomId ?? "",
            content: content,
            createdAt: formatter.string(from: createdAt ?? Date()),
            updatedAt: formatter.string(from: updatedAt ?? Date()),
            sender: sender,
            files: files.isEmpty ? nil : files
        )
    }
    
    // DTO에서 생성
    static func fromDTO(_ dto: ChatResponseDTO, context: NSManagedObjectContext) -> ChatMessageEntity {
        let entity = ChatMessageEntity(context: context)
        let formatter = ISO8601DateFormatter()
        
        entity.chatId = dto.chatId
        entity.roomId = dto.roomId
        entity.content = dto.content
        entity.createdAt = parseServerDateWithMilliseconds(dto.createdAt)
        entity.updatedAt = parseServerDateWithMilliseconds(dto.updatedAt)
        entity.senderId = dto.sender.userId
        entity.senderNick = dto.sender.nick
        entity.senderName = dto.sender.name
        entity.senderProfileImage = dto.sender.profileImage
        entity.files = dto.files ?? []
        
        return entity
    }
    
    static func parseServerDateWithMilliseconds(_ dateString: String) -> Date {
        
        // ISO8601DateFormatter로 밀리초 포함 파싱
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        return Date()
    }
}

extension ChatRoomEntity {
    
    // Participants 배열 처리
    var participants: [SenderDTO] {
        get {
            guard let data = participantsData,
                  let participants = try? JSONDecoder().decode([SenderDTO].self, from: data) else {
                return []
            }
            return participants
        }
        set {
            participantsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // ChatRoomResponseDTO에서 엔티티 생성
    static func fromDTO(_ dto: ChatRoomResponseDTO, context: NSManagedObjectContext) -> ChatRoomEntity {
        let entity = ChatRoomEntity(context: context)
        let formatter = ISO8601DateFormatter()
        
        entity.roomId = dto.roomId
        entity.createdAt = formatter.date(from: dto.createdAt) ?? Date()
        entity.updatedAt = formatter.date(from: dto.updatedAt) ?? Date()
        entity.participants = dto.participants
        entity.lastMessage = dto.lastChat?.content
        
        if let lastChatTime = dto.lastChat?.createdAt {
            entity.lastMessageTime = formatter.date(from: lastChatTime)
        }
        
        return entity
    }
    
    // 엔티티를 DTO로 변환
    func toDTO() -> ChatRoomResponseDTO {
        let formatter = ISO8601DateFormatter()
        
        var lastChat: ChatResponseDTO? = nil
        if let lastMessage = lastMessage,
           let lastMessageTime = lastMessageTime {
            lastChat = ChatResponseDTO(
                chatId: "",
                roomId: roomId ?? "",
                content: lastMessage,
                createdAt: formatter.string(from: lastMessageTime),
                updatedAt: formatter.string(from: lastMessageTime),
                sender: participants.first ?? SenderDTO(userId: "", nick: "", name: nil, profileImage: nil, introduction: nil, hashTags: nil),
                files: nil
            )
        }
        
        return ChatRoomResponseDTO(
            roomId: roomId ?? "",
            createdAt: formatter.string(from: createdAt ?? Date()),
            updatedAt: formatter.string(from: updatedAt ?? Date()),
            participants: participants,
            lastChat: lastChat
        )
    }
}
