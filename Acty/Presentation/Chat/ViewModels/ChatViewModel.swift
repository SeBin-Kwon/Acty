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
    let userId: String
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var chatUserNickname: String?
    }
    
    init(chatService: ChatServiceProtocol, userId: String) {
        self.chatService = chatService
        self.userId = userId
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                guard let self else { return }
                Task {
                    let result = await self.chatService.createChat(id: self.userId)
                    print(result ?? "채팅 없음")
                }
            }
            .store(in: &cancellables)
    }
}
