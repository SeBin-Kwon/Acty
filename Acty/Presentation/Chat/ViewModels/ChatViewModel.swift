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
    let userId: String
    private var roomId: String?
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
        var sendMessage = PassthroughSubject<String, Never>()
        var loadMoreMessages = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var messages = [ChatResponseDTO]()
        var chatUserNickname: String?
        var isLoading = CurrentValueSubject<Bool, Never>(false)
        var errorMessage = PassthroughSubject<String, Never>()
        var chatRoomCreated = PassthroughSubject<String, Never>()
    }
    
    init(chatService: ChatServiceProtocol, chatRepository: ChatRepositoryProtocol, userId: String) {
        self.chatService = chatService
        self.chatRepository = chatRepository
        self.userId = userId
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                self?.createOrGetChatRoom()
            }
            .store(in: &cancellables)
        
        output.chatRoomCreated
            .sink { [weak self] roomId in
                self?.roomId = roomId
                self?.loadMessages()
            }
            .store(in: &cancellables)
        
        input.sendMessage
            .sink { [weak self] content in
                self?.sendMessage(content: content)
            }
            .store(in: &cancellables)
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
                let sentMessage = try await chatRepository.sendMessage(message, roomId: roomId)
                
                await MainActor.run {
                    self.output.messages.append(sentMessage)
                }
                
            } catch {
                await MainActor.run {
                    self.output.errorMessage.send("메시지 전송 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}
