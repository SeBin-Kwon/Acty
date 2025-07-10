//
//  ChatService.swift
//  Acty
//
//  Created by Sebin Kwon on 7/1/25.
//

import Foundation

protocol ChatServiceProtocol {
    func createChat(id: String) async -> ChatRoomResponseDTO?
    func getChatRooms() async -> [ChatRoomResponseDTO]
    func getMessages(roomId: String, date: String?) async -> [ChatResponseDTO]
    func sendMessage(roomId: String, message: ChatRequestDTO) async -> ChatResponseDTO?
    func uploadFiles(roomId: String, files: [String]) async -> Bool
}

final class ChatService: ChatServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    // MARK: - 채팅방 생성/조회
    func createChat(id: String) async -> ChatRoomResponseDTO? {
        do {
            let result: ChatRoomResponseDTO = try await networkManager.fetchResults(api: ChatEndPoint.createChats(id))
            print("채팅방 생성/조회 성공: \(result.roomId)")
            return result
        } catch {
            print("채팅방 생성/조회 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - 채팅방 목록 조회
    func getChatRooms() async -> [ChatRoomResponseDTO] {
        do {
            let result: [ChatRoomResponseDTO] = try await networkManager.fetchResults(api: ChatEndPoint.getChats)
            print("채팅방 목록 조회 성공: \(result.count)개")
            return result
        } catch {
            print("채팅방 목록 조회 실패: \(error)")
            return []
        }
    }
    
    // MARK: - 특정 채팅방 메시지 조회
    func getMessages(roomId: String, date: String?) async -> [ChatResponseDTO] {
        do {
            let result: ChatMessagesResponseDTO = try await networkManager.fetchResults(
                api: ChatEndPoint.getChatHistory(roomId, date ?? "")
            )
            print("메시지 조회 성공: \(result.data.count)개")
            return result.data
        } catch {
            print("메시지 조회 실패: \(error)")
            return []
        }
    }
    
    // MARK: - 메시지 전송
    func sendMessage(roomId: String, message: ChatRequestDTO) async -> ChatResponseDTO? {
        do {
            let result: ChatResponseDTO = try await networkManager.fetchResults(
                api: ChatEndPoint.sendChat(roomId, message)
            )
            print("메시지 전송 성공: \(result.chatId)")
            return result
        } catch {
            print("메시지 전송 실패: \(error)")
            return nil
        }
    }
    
    // MARK: - 파일 업로드
    func uploadFiles(roomId: String, files: [String]) async -> Bool {
        do {
            let _: EmptyResponse = try await networkManager.fetchResults(
                api: ChatEndPoint.uploadChatFiles(roomId, files)
            )
            print("파일 업로드 성공")
            return true
        } catch {
            print("파일 업로드 실패: \(error)")
            return false
        }
    }
}

// 파일 업로드 응답용 (성공/실패만 확인)
struct EmptyResponse: Codable {}
