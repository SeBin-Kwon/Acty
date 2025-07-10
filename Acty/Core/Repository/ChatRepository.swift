//
//  ChatRepository.swift
//  Acty
//
//  Created by Sebin Kwon on 7/9/25.
//

import Foundation

protocol ChatRepositoryProtocol {
    func getLocalMessages(roomId: String) -> [ChatResponseDTO]
    func syncMessagesFromServer(roomId: String) async throws
    func sendMessage(_ message: ChatRequestDTO, roomId: String) async throws -> ChatResponseDTO
    func createOrGetChatRoom(opponentId: String) async throws -> ChatRoomResponseDTO
    func getChatRoomsList() async throws -> [ChatRoomResponseDTO]
    func deleteAllMessages(roomId: String) async throws
}

final class ChatRepository: ChatRepositoryProtocol {
    
    private let chatService: ChatServiceProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    init(chatService: ChatServiceProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.chatService = chatService
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - 로컬 메시지 조회
    func getLocalMessages(roomId: String) -> [ChatResponseDTO] {
        do {
            let messages = try coreDataManager.getMessages(for: roomId)
            print("로컬 메시지 조회 성공: \(messages.count)개")
            return messages
        } catch {
            print("로컬 메시지 조회 실패: \(error)")
            return []
        }
    }
    
    // MARK: - 서버에서 최신 메시지 동기화
    func syncMessagesFromServer(roomId: String) async throws {
        print("서버 메시지 동기화 시작 - roomId: \(roomId)")
        
        // 1. 마지막 메시지 날짜를 cursor로 사용
        let lastMessageDate = try? coreDataManager.getLastMessageDate(for: roomId)
        let cursor = lastMessageDate?.ISO8601Format()
        
        // 2. 서버에서 최신 메시지 가져오기
        let newMessages = await chatService.getMessages(roomId: roomId, date: cursor)
        
        // 3. 새 메시지가 있으면 로컬에 저장
        if !newMessages.isEmpty {
            try coreDataManager.saveMessages(newMessages, for: roomId)
            print("새 메시지 \(newMessages.count)개 저장 완료")
        } else {
            print("새 메시지 없음")
        }
    }
    
    // MARK: - 메시지 전송
    func sendMessage(_ message: ChatRequestDTO, roomId: String) async throws -> ChatResponseDTO {
        print("메시지 전송 시작 - roomId: \(roomId)")
        
        // 1. 서버로 메시지 전송
        guard let sentMessage = await chatService.sendMessage(roomId: roomId, message: message) else {
            throw AppError.chatError
        }
        
        // 2. 전송 성공한 메시지를 로컬에 저장
        try coreDataManager.saveMessage(sentMessage)
        print("메시지 전송 및 저장 완료")
        
        return sentMessage
    }
    
    // MARK: - 채팅방 생성/조회
    func createOrGetChatRoom(opponentId: String) async throws -> ChatRoomResponseDTO {
        print("채팅방 생성/조회 시작 - opponentId: \(opponentId)")
        
        // 1. 서버에서 채팅방 생성/조회
        guard let chatRoom = await chatService.createChat(id: opponentId) else {
            throw AppError.chatError
        }
        
        // 2. 채팅방 정보를 로컬에 저장
        try coreDataManager.saveChatRoom(chatRoom)
        print("채팅방 생성/조회 완료 - roomId: \(chatRoom.roomId)")
        
        return chatRoom
    }
    
    // MARK: - 채팅방 목록 조회
    func getChatRoomsList() async throws -> [ChatRoomResponseDTO] {
        print("채팅방 목록 조회 시작")
        
        // 1. 먼저 로컬 채팅방 목록 조회
        let _ = try coreDataManager.getChatRooms()
        
        // 2. 서버에서 최신 채팅방 목록 가져오기
        let serverChatRooms = await chatService.getChatRooms()
        
        // 3. 서버 데이터를 로컬에 저장
        for chatRoom in serverChatRooms {
            try coreDataManager.saveChatRoom(chatRoom)
        }
        
        // 4. 최신 로컬 데이터 반환
        let updatedChatRooms = try coreDataManager.getChatRooms()
        print("채팅방 목록 조회 완료: \(updatedChatRooms.count)개")
        
        return updatedChatRooms
    }
    
    func deleteAllMessages(roomId: String) async throws {
        try coreDataManager.deleteAllMessages(for: roomId)
        print("모든 메시지 삭제 완료")
    }
}

private extension ChatRepository {
    /// 메시지 중복 제거
    func removeDuplicateMessages(_ messages: [ChatResponseDTO]) -> [ChatResponseDTO] {
        var seen = Set<String>()
        return messages.filter { message in
            if seen.contains(message.chatId) {
                return false
            }
            seen.insert(message.chatId)
            return true
        }
    }
}
