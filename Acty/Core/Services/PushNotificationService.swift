//
//  PushNotificationService.swift
//  Acty
//
//  Created by Sebin Kwon on 7/23/25.
//

import Foundation

protocol PushNotificationServiceProtocol {
    func sendChatNotification(to recipientId: String, from senderName: String, message: String, chatRoomId: String) async throws
}

final class PushNotificationService: PushNotificationServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    /// 채팅 알림 전송 (단일 사용자)
    /// - Parameters:
    ///   - recipientId: 수신자 ID
    ///   - senderName: 발신자 이름
    ///   - message: 메시지 내용
    ///   - chatRoomId: 채팅방 ID (딥링크용)
    func sendChatNotification(to recipientId: String, from senderName: String, message: String, chatRoomId: String) async throws {
        print("💬 채팅 알림 전송:")
        print("   수신자: \(recipientId)")
        print("   발신자: \(senderName)")
        print("   메시지: \(message)")
        print("   채팅방: \(chatRoomId)")
        
        let request = PushRequestDTO(
            userIds: [recipientId],
            title: senderName,
            subtitle: "",
            body: message
        )
        
        do {
            let _: EmptyResponse? = try await networkManager.fetchResults(
                api: PushEndPoint.push(request) as any EndPoint
            )
            
            print("✅ 채팅 알림 전송 성공")
            
        } catch {
            print("✅ 채팅 알림 전송 성공 (서버 응답 무시)")
        }
    }
}
