//
//  CoreDataManager.swift
//  Acty
//
//  Created by Sebin Kwon on 7/5/25.
//

import Foundation
import CoreData
import Combine

protocol ChatDataManagerProtocol {
    func saveMessages(_ messages: [ChatMessageDTO], for roomId: String) throws
//    func getMessages(for roomId: String) throws -> [ChatMessageDTO]
    func getLastMessageDate(for roomId: String) throws -> Date?
    func saveMessage(_ message: ChatMessageDTO) throws
    func deleteAllMessages(for roomId: String) throws
//    func getChatRooms() throws -> [ChatRoomDTO]
//    func saveChatRoom(_ room: ChatRoomDTO) throws
}

final class ChatDataManager: ChatDataManagerProtocol {
    
    static let shared = ChatDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatDataModel") // .xcdatamodeld 파일명
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - 메시지 관련 메소드
    
    /// 여러 메시지를 한번에 저장
    func saveMessages(_ messages: [ChatMessageDTO], for roomId: String) throws {
        for message in messages {
            // 이미 존재하는 메시지인지 확인
            let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "chatId == %@", message.chatId)
            
            let existingMessages = try context.fetch(fetchRequest)
            
            if existingMessages.isEmpty {
                // 새로운 메시지만 저장
//                _ = ChatMessageEntity.fromDTO(message, context: context)
            }
        }
        
        try saveContext()
    }
    
    /// 특정 채팅방의 모든 메시지 조회
//    func getMessages(for roomId: String) throws -> [ChatMessageDTO] {
//        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "roomId == %@", roomId)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
//        
//        let entities = try context.fetch(fetchRequest)
////        return entities.map { $0.toDTO() }
//    }
    
    /// 특정 채팅방의 가장 최근 메시지 날짜 조회
    func getLastMessageDate(for roomId: String) throws -> Date? {
        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", roomId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        let entities = try context.fetch(fetchRequest)
        return entities.first?.createdAt
    }
    
    /// 단일 메시지 저장
    func saveMessage(_ message: ChatMessageDTO) throws {
        // 중복 체크
        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "chatId == %@", message.chatId)
        
        let existingMessages = try context.fetch(fetchRequest)
        
        if existingMessages.isEmpty {
//            _ = ChatMessageEntity.fromDTO(message, context: context)
            try saveContext()
        }
    }
    
    /// 특정 채팅방의 모든 메시지 삭제
    func deleteAllMessages(for roomId: String) throws {
        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", roomId)
        
        let entities = try context.fetch(fetchRequest)
        
        for entity in entities {
            context.delete(entity)
        }
        
        try saveContext()
    }
    
    // MARK: - 채팅방 관련 메소드
    
    /// 모든 채팅방 조회
    func getChatRooms() throws -> [ChatRoomResponseDTO] {
        let fetchRequest: NSFetchRequest<ChatRoomEntity> = ChatRoomEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
        
        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDTO() }
    }
    
    /// 채팅방 저장 또는 업데이트
    func saveChatRoom(_ room: ChatRoomResponseDTO) throws {
        // 기존 채팅방 확인
        let fetchRequest: NSFetchRequest<ChatRoomEntity> = ChatRoomEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", room.roomId)
        
        let existingRooms = try context.fetch(fetchRequest)
        
        if let existing = existingRooms.first {
            // 기존 채팅방 업데이트
            let formatter = ISO8601DateFormatter()
            existing.updatedAt = formatter.date(from: room.updatedAt) ?? Date()
            existing.participants = room.participants
            existing.lastMessage = room.lastChat?.content
            
            if let lastChatTime = room.lastChat?.createdAt {
                existing.lastMessageTime = formatter.date(from: lastChatTime)
            }
        } else {
            // 새로운 채팅방 생성
            _ = ChatRoomEntity.fromDTO(room, context: context)
        }
        
        try saveContext()
    }
}

struct ChatMessageDTO: Codable {
    let content: String
    let files: [ChatFiles]
}

struct ChatFiles: Codable {
    let url: String
}
