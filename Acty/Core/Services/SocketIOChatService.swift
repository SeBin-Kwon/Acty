//
//  SocketIOChatService.swift
//  Acty
//
//  Created by Sebin Kwon on 7/11/25.
//

import Foundation
import Combine
import SocketIO

protocol SocketIOChatServiceProtocol {
    var connectionState: CurrentValueSubject<SocketConnectionState, Never> { get }
    var messageReceived: PassthroughSubject<ChatResponseDTO, Never> { get }
    
    func connect(roomId: String)
    func disconnect()
    func sendMessage(_ message: ChatRequestDTO, roomId: String)
}

enum SocketConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)
}

final class SocketIOChatService: SocketIOChatServiceProtocol {
    
    // MARK: - Properties
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let tokenService: TokenServiceProtocol
    private var currentRoomId: String?
    
    let connectionState = CurrentValueSubject<SocketConnectionState, Never>(.disconnected)
    let messageReceived = PassthroughSubject<ChatResponseDTO, Never>()
    
    // MARK: - Initialization
    init(tokenService: TokenServiceProtocol) {
        self.tokenService = tokenService
    }
    
    // MARK: - Connection Management
    func connect(roomId: String) {
        print("🔗 Socket.IO 연결 시도 - roomId: \(roomId)")
        
        // 이미 같은 방에 연결되어 있으면 무시
        if currentRoomId == roomId && connectionState.value == .connected {
            print("✅ 이미 해당 방에 연결됨")
            return
        }
        
        // 기존 연결 해제
        disconnect()
        
        currentRoomId = roomId
        connectionState.send(.connecting)
        
        setupSocket(roomId: roomId)
        socket?.connect()
    }
    
    func disconnect() {
        print("🔗 Socket.IO 연결 해제")
        
        socket?.disconnect()
        socket?.removeAllHandlers()
        socket = nil
        manager = nil
        currentRoomId = nil
        connectionState.send(.disconnected)
    }
    
    // MARK: - Message Sending
    func sendMessage(_ message: ChatRequestDTO, roomId: String) {
        guard let socket = socket, socket.status == .connected else {
            print("❌ Socket.IO가 연결되지 않음 - 메시지 전송 실패")
            return
        }
        
        // ChatRequestDTO를 Dictionary로 변환
        let messageData: [String: Any] = [
            "content": message.content,
            "files": message.files.map { ["url": $0.url] }
        ]
        
        print("📤 Socket.IO 메시지 전송: \(message.content)")
        // 🔧 서버 문서에 따라 "chat" 이벤트로 전송
        socket.emit("chat", messageData)
    }
    
    // MARK: - Private Methods
    private func setupSocket(roomId: String) {
        // Socket.IO URL 생성: baseURL:port/chats-room_id
        let socketURL = "\(BASE_URL.replacingOccurrences(of: "v1", with: ""))"
        
        guard let url = URL(string: socketURL.replacingOccurrences(of: "http", with: "ws")) else {
            print("❌ 잘못된 Socket.IO URL: \(socketURL)")
            connectionState.send(.error("잘못된 URL"))
            return
        }
        
        print("🔗 Socket.IO URL: \(url.absoluteString)")
        
        // Headers 추가
        var headers: [String: String] = [:]
        headers["SeSACKey"] = API_KEY
        
        if let token = try? tokenService.getAccessToken() {
            headers["Authorization"] = "\(token)"
        }
        
        let config: SocketIOClientConfiguration = [
                    .log(true),
                    .compress,
                    .extraHeaders(headers)
                ]
        
        // SocketManager 생성
        manager = SocketManager(socketURL: url, config: config)
        socket = manager?.socket(forNamespace: "/chats-\(roomId)")
        
        setupEventHandlers()
    }
    
    private func setupEventHandlers() {
        guard let socket = socket else { return }
        
        // 연결 성공
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("✅ Socket.IO 연결 성공: SOCKET IS CONNECTED")
            self?.connectionState.send(.connected)
        }
        
        // 연결 실패
        socket.on(clientEvent: .error) { [weak self] data, ack in
            print("❌ Socket.IO 연결 오류: \(data)")
            let errorMessage = data.first as? String ?? "알 수 없는 오류"
            self?.connectionState.send(.error(errorMessage))
        }
        
        // 연결 해제
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("🔗 Socket.IO 연결 해제: SOCKET IS DISCONNECTED")
            self?.connectionState.send(.disconnected)
        }
        
        // 🔧 서버 문서에 따라 "chat" 이벤트로 메시지 수신
        socket.on("chat") { [weak self] data, ack in
            print("📨 CHAT RECEIVED: \(data)")
            self?.handleMessage(data: data)
        }
    }
    
    private func handleMessage(data: [Any]) {
        print("📨 Socket.IO 메시지 수신: \(data)")
        
        guard let messageData = data.first else {
            print("❌ 메시지 데이터가 없음")
            return
        }
        
        do {
            // Data를 JSON으로 변환
            let jsonData = try JSONSerialization.data(withJSONObject: messageData)
            
            // ChatResponseDTO로 디코딩
            let chatMessage = try JSONDecoder().decode(ChatResponseDTO.self, from: jsonData)
            
            print("✅ 메시지 디코딩 성공: \(chatMessage.content ?? "nil")")
            messageReceived.send(chatMessage)
            
        } catch {
            print("❌ 메시지 디코딩 실패: \(error)")
            print("원본 데이터: \(messageData)")
        }
    }
}
