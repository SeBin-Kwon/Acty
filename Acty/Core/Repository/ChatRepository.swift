//
//  ChatRepository.swift
//  Acty
//
//  Created by Sebin Kwon on 7/9/25.
//

import Foundation

protocol ChatRepositoryProtocol {
    func saveMessages(_ messages: [ChatResponseDTO], roomId: String) async throws
    func getLocalMessages(roomId: String) -> [ChatResponseDTO]
    func syncMessagesFromServer(roomId: String) async throws
    func sendMessage(_ message: ChatRequestDTO, roomId: String) async throws -> ChatResponseDTO
}

final class ChatRepository: ChatRepositoryProtocol {
    
    private let chatService: ChatServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    init(chatService: ChatServiceProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.chatService = chatService
        self.coreDataManager = coreDataManager
    }
    
    func saveMessages(_ messages: [ChatResponseDTO], roomId: String) async throws {
        do {
            return try coreDataManager.saveMessages(messages, for: roomId)
        } catch {
            print("메시지 저장 실패")
        }
    }
    
    func getLocalMessages(roomId: String) -> [ChatResponseDTO] {
        do {
            return try coreDataManager.getMessages(for: roomId)
        } catch {
            print("로컬 메시지 조회 실패: \(error)")
            return []
        }
    }
    
    func syncMessagesFromServer(roomId: String) async throws {
        // 서버에서 최신 메시지 가져오기
        let lastMessageDate = try coreDataManager.getLastMessageDate(for: roomId)
        let cursor = lastMessageDate?.ISO8601Format() // 마지막 메시지 시간을 cursor로 사용
        
        let newMessages = await chatService.getMessages(roomId: roomId, cursor: cursor)
        
        // 로컬에 저장
        try coreDataManager.saveMessages(newMessages, for: roomId)
    }
    
    func sendMessage(_ message: ChatRequestDTO, roomId: String) async throws -> ChatResponseDTO {
        // 서버로 메시지 전송
        guard let sentMessage = await chatService.sendMessage(roomId: roomId, content: message.content, files: message.files.map { $0.url }) else {
            throw AppError.chatError
        }
        
        // 로컬에 저장
        try coreDataManager.saveMessage(sentMessage)
        
        return sentMessage
    }
}
