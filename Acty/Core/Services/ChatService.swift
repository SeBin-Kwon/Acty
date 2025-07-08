//
//  ChatService.swift
//  Acty
//
//  Created by Sebin Kwon on 7/1/25.
//

import Foundation

protocol ChatServiceProtocol {
    func createChat(id: String) async -> ChatRoomResponseDTO?
}

final class ChatService: ChatServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func createChat(id: String) async -> ChatRoomResponseDTO? {
        do {
            let result: ChatRoomResponseDTO = try await networkManager.fetchResults(api: ChatEndPoint.createChats(id))
            print("채팅 만들기 성공")
            print(result)
            return result
        } catch {
            print("채팅 만들기 실패")
            return nil
        }
    }
    
    /*
     func fetchActivityDetails(id: String) async throws -> ActivityDetail {
         let result: ActivityDetailResponseDTO = try await networkManager.fetchResults(api: ActivityEndPoint.activityDetail(id))
         print("액티비티 Detail fetch 성공")
         return result.toEntity()
     }
     */
}
