//
//  ChatViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 7/8/25.
//

import Foundation
import Combine

final class ChatViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    private let chatService: ChatServiceProtocol
    private let chatRepository: ChatRepositoryProtocol
    private let socketIOChatService: SocketIOChatServiceProtocol
    private let pushNotificationService: PushNotificationServiceProtocol
    let userId: String
    private var roomId: String?
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
        var onDisappear = PassthroughSubject<Void, Never>()
        var sendMessage = PassthroughSubject<String, Never>()
        var loadMoreMessages = PassthroughSubject<Void, Never>()
        var onForeground = PassthroughSubject<Void, Never>()
        var onBackground = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var messages = [ChatResponseDTO]()
        var chatUserNickname: String?
        var isLoading = CurrentValueSubject<Bool, Never>(false)
        var errorMessage = PassthroughSubject<String, Never>()
        var chatRoomCreated = PassthroughSubject<String, Never>()
        var socketConnectionState = CurrentValueSubject<SocketConnectionState, Never>(.disconnected)
    }
    
    init(chatService: ChatServiceProtocol, chatRepository: ChatRepositoryProtocol, socketIOChatService: SocketIOChatServiceProtocol, pushNotificationService: PushNotificationServiceProtocol, userId: String) {
        self.chatService = chatService
        self.chatRepository = chatRepository
        self.socketIOChatService = socketIOChatService
        self.pushNotificationService = pushNotificationService
        self.userId = userId
        transform()
        setupRealtimeBinding()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                self?.createOrGetChatRoom()
            }
            .store(in: &cancellables)
        
        input.onDisappear
           .sink { [weak self] _ in
               self?.disconnectSocket()
           }
           .store(in: &cancellables)
        
        output.chatRoomCreated
            .sink { [weak self] roomId in
                self?.roomId = roomId
                self?.loadMessages()
                self?.connectSocket(roomId: roomId)
            }
            .store(in: &cancellables)
        
        input.sendMessage
            .sink { [weak self] content in
                self?.sendMessage(content: content)
            }
            .store(in: &cancellables)
        
        input.onForeground
            .sink { [weak self] _ in
                if let roomId = self?.roomId {
                    print("📱 포그라운드 복귀 - Socket.IO 재연결")
                    self?.connectSocket(roomId: roomId)
                }
            }
            .store(in: &cancellables)
        
        input.onBackground
            .sink { [weak self] _ in
                print("📱 백그라운드 진입 - Socket.IO 해제")
                self?.disconnectSocket()
            }
            .store(in: &cancellables)

    }
    
    private func setupRealtimeBinding() {
        // Socket.IO 연결 상태 바인딩
        socketIOChatService.connectionState
            .sink { [weak self] state in
                self?.output.socketConnectionState.send(state)
                print("🔗 Socket.IO 상태: \(state)")
            }
            .store(in: &cancellables)
        
        // 실시간 메시지 수신
        chatRepository.realtimeMessageReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleRealtimeMessage(message)
            }
            .store(in: &cancellables)
    }
    
    private func handleRealtimeMessage(_ message: ChatResponseDTO) {
        print("🔥 실시간 메시지 UI 처리: \(message.content ?? "nil")")
        
        // 중복 메시지 체크
        if !output.messages.contains(where: { $0.chatId == message.chatId }) {
            output.messages.append(message)
            print("✅ 새 메시지 UI 추가됨")
        } else {
            print("⚠️ 중복 메시지 무시됨")
        }
    }
    
    // MARK: - Socket.IO 관리
    private func connectSocket(roomId: String) {
        print("🔗 Socket.IO 연결 시작 - roomId: \(roomId)")
        socketIOChatService.connect(roomId: roomId)
    }
    
    private func disconnectSocket() {
        print("🔗 Socket.IO 연결 해제")
        socketIOChatService.disconnect()
    }
    
    private func createOrGetChatRoom() {
        output.isLoading.send(true)
        
        Task {
            do {
                let result = await chatService.createChat(id: userId)
                
                await MainActor.run {
                    if let chatRoom = result {
                        print("📱 채팅방 생성 결과:")
                        print("   - 요청한 상대방 userId: \(self.userId)")
                        print("   - participants: \(chatRoom.participants.map { "\($0.nick)(\($0.userId))" })")
                        if let opponent = chatRoom.participants.first(where: { $0.userId == userId }) {
                            print("✅ 상대방 발견: \(opponent.nick)")
                            
                            self.output.chatUserNickname = opponent.nick
                            self.output.chatRoomCreated.send(chatRoom.roomId)
                            self.output.isLoading.send(false)
                        }
                        
                    } else {
                        self.output.errorMessage.send("채팅방 생성에 실패했습니다.")
                        self.output.isLoading.send(false)
                    }
                }
            }
        }

    }
    
    private func loadMessages() {
        guard let roomId = roomId else { return }
        
        // 1. 먼저 로컬 메시지 로드 (빠른 UI 표시)
        let localMessages = chatRepository.getLocalMessages(roomId: roomId)
        output.messages = localMessages
        
        // 2. 서버에서 최신 메시지 동기화
        Task {
            do {
                try await chatRepository.syncMessagesFromServer(roomId: roomId)

                let updatedMessages = chatRepository.getLocalMessages(roomId: roomId)
                
                await MainActor.run {
                    self.output.messages = updatedMessages
                    print("채팅방메시지들~~@@@@@@@~~~~")
                    print(self.output.messages)
                    self.output.isLoading.send(false)
                }
            } catch {
                await MainActor.run {
                    self.output.errorMessage.send("메시지 로드 실패: \(error.localizedDescription)")
                    self.output.isLoading.send(false)
                }
            }
        }
    }
    
    private func sendMessage(content: String) {
        guard let roomId = roomId else {
            output.errorMessage.send("채팅방이 준비되지 않았습니다.")
            return
        }
        
        let message = ChatRequestDTO(content: content, files: [])
        
        Task {
            do {
                _ = try await chatRepository.sendMessage(message, roomId: roomId)
                print("메시지 전송 완료")
                try await sendPushNotification(for: content)
            } catch {
                await MainActor.run {
                    self.output.errorMessage.send("메시지 전송 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendPushNotification(for messageContent: String) async throws {
        guard let roomId = roomId,
              let currentUserNickname = DIContainer.shared.currentUser?.nick else {
            print("⚠️ 푸시 알림 전송 건너뜀 - 필요한 정보 부족")
            return
        }
        
        do {
            try await pushNotificationService.sendChatNotification(
                to: userId,                        // 상대방 ID (수신자)
                from: currentUserNickname,         // 현재 사용자 닉네임 (발신자)
                message: messageContent,           // 메시지 내용
                chatRoomId: roomId                 // 채팅방 ID
            )
            
            print("✅ 푸시 알림 전송 성공")
            
        } catch {
            print("⚠️ 푸시 알림 전송 실패: \(error)")
            // 푸시 실패는 채팅 자체에는 영향 주지 않음 (조용히 실패)
        }
    }
}
