//
//  CoreDataManager.swift
//  Acty
//
//  Created by Sebin Kwon on 7/5/25.
//

import Foundation
import CoreData
import Combine

protocol CoreDataManagerProtocol {
    func saveMessages(_ messages: [ChatResponseDTO], for roomId: String) throws
    func getMessages(for roomId: String) throws -> [ChatResponseDTO]
    func getLastMessageDate(for roomId: String) throws -> Date?
    func saveMessage(_ message: ChatResponseDTO) throws
    func deleteAllMessages(for roomId: String) throws
    func getChatRooms() throws -> [ChatRoomResponseDTO]
    func saveChatRoom(_ room: ChatRoomResponseDTO) throws
}

final class CoreDataManager: CoreDataManagerProtocol {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
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

    
    /// 여러 메시지를 한번에 저장
    func saveMessages(_ messages: [ChatResponseDTO], for roomId: String) throws {
        for message in messages {
            // 이미 존재하는 메시지인지 확인
            let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "chatId == %@", message.chatId)
            
            let existingMessages = try context.fetch(fetchRequest)
            
            if existingMessages.isEmpty {
                // 새로운 메시지만 저장
                _ = ChatMessageEntity.fromDTO(message, context: context)
            }
        }
        
        try saveContext()
    }
    
    /// 특정 채팅방의 모든 메시지 조회
    func getMessages(for roomId: String) throws -> [ChatResponseDTO] {
        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "roomId == %@", roomId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let entities = try context.fetch(fetchRequest)
        return entities.map { $0.toDTO() }
    }
    
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
    func saveMessage(_ message: ChatResponseDTO) throws {
        // 중복 체크
        let fetchRequest: NSFetchRequest<ChatMessageEntity> = ChatMessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", message.chatId)
        
        let existingMessages = try context.fetch(fetchRequest)
        
        if existingMessages.isEmpty {
            _ = ChatMessageEntity.fromDTO(message, context: context)
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
    
    func getChatRooms() throws -> [ChatRoomResponseDTO] {
        let fetchRequest: NSFetchRequest<ChatRoomEntity> = ChatRoomEntity.fetchRequest()
        
        // 🔧 서버에서 이미 정렬되어 오므로 updatedAt 기준 정렬만
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        let entities = try context.fetch(fetchRequest)
        let dtos = entities.map { $0.toDTO() }
        
        print("📋 채팅방 목록 조회 완료: \(dtos.count)개")
        return dtos
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
            existing.lastChat = room.lastChat
        } else {
            // 새로운 채팅방 생성
            _ = ChatRoomEntity.fromDTO(room, context: context)
        }
        
        try saveContext()
    }
}


