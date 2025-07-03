//
//  ChatEntity.swift
//  Acty
//
//  Created by Sebin Kwon on 7/3/25.
//

import Foundation
import CoreData

@objc(ChatRoomEntity)
public class ChatRoomEntity: NSManagedObject {
    @NSManaged public var roomId: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var participantsData: Data?
    @NSManaged public var lastMessage: String?
    @NSManaged public var lastMessageTime: Date?
    @NSManaged public var messages: NSSet?
    
    // Participants 배열 처리
    var participants: [ParticipantDTO] {
        get {
            guard let data = participantsData,
                  let participants = try? JSONDecoder().decode([ParticipantDTO].self, from: data) else {
                return []
            }
            return participants
        }
        set {
            participantsData = try? JSONEncoder().encode(newValue)
        }
    }
}

extension ChatRoomEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatRoomEntity> {
        return NSFetchRequest<ChatRoomEntity>(entityName: "ChatRoomEntity")
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
        
        var lastChat: LastChatDTO? = nil
        if let lastMessage = lastMessage,
           let lastMessageTime = lastMessageTime {
            lastChat = LastChatDTO(
                chatId: "",
                roomId: roomId,
                content: lastMessage,
                createdAt: formatter.string(from: lastMessageTime),
                updatedAt: formatter.string(from: lastMessageTime),
                sender: participants.first ?? ParticipantDTO(userId: "", nick: "", profileImage: nil, introduction: nil),
                files: nil
            )
        }
        
        return ChatRoomResponseDTO(
            roomId: roomId,
            createdAt: formatter.string(from: createdAt),
            updatedAt: formatter.string(from: updatedAt),
            participants: participants,
            lastChat: lastChat
        )
    }
}

@objc(ChatMessageEntity)
public class ChatMessageEntity: NSManagedObject {
    @NSManaged public var chatId: String
    @NSManaged public var roomId: String
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var senderId: String
    @NSManaged public var senderNick: String
    @NSManaged public var senderName: String?
    @NSManaged public var senderProfileImage: String?
    @NSManaged public var senderIntroduction: String?
    @NSManaged public var filesData: Data?
    @NSManaged public var chatRoom: ChatRoomEntity?
    
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
}

extension ChatMessageEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatMessageEntity> {
        return NSFetchRequest<ChatMessageEntity>(entityName: "ChatMessageEntity")
    }
    
    // DTO로 변환
//    func toDTO() -> ChatMessageDTO {
//        let sender = SenderDTO(
//            userId: senderId,
//            nick: senderNick,
//            name: senderName,
//            introduction: senderIntroduction,
//            profileImage: senderProfileImage,
//            hashTags: nil
//        )
//        
//        let formatter = ISO8601DateFormatter()
//        
//        return ChatMessageDTO(
//            chatId: chatId,
//            roomId: roomId,
//            content: content,
//            createdAt: formatter.string(from: createdAt),
//            updatedAt: formatter.string(from: updatedAt),
//            sender: sender,
//            files: files.isEmpty ? nil : files
//        )
//    }
    
    // DTO에서 생성
//    static func fromDTO(_ dto: ChatMessageDTO, context: NSManagedObjectContext) -> ChatMessageEntity {
//        let entity = ChatMessageEntity(context: context)
//        let formatter = ISO8601DateFormatter()
//        
//        entity.chatId = dto.chatId
//        entity.roomId = dto.roomId
//        entity.content = dto.content
//        entity.createdAt = formatter.date(from: dto.createdAt) ?? Date()
//        entity.updatedAt = formatter.date(from: dto.updatedAt) ?? Date()
//        entity.senderId = dto.sender.userId
//        entity.senderNick = dto.sender.nick
//        entity.senderName = dto.sender.name
//        entity.senderProfileImage = dto.sender.profileImage
//        entity.senderIntroduction = dto.sender.introduction
//        entity.files = dto.files ?? []
//        
//        return entity
//    }
}
