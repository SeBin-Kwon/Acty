//
//  ChatListViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 7/10/25.
//

import Foundation
import Combine

final class ChatListViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    private let chatService: ChatServiceProtocol
    private let chatRepository: ChatRepositoryProtocol
    
    struct Input {
//        var onAppear = PassthroughSubject<Void, Never>()
//        var sendMessage = PassthroughSubject<String, Never>()
//        var loadMoreMessages = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
//        var messages = [ChatResponseDTO]()
//        var chatUserNickname: String?
//        var isLoading = CurrentValueSubject<Bool, Never>(false)
//        var errorMessage = PassthroughSubject<String, Never>()
//        var chatRoomCreated = PassthroughSubject<String, Never>()
    }
    
    init(chatService: ChatServiceProtocol, chatRepository: ChatRepositoryProtocol) {
        self.chatService = chatService
        self.chatRepository = chatRepository
        transform()
    }
    
    func transform() {
        print("")
    }
}
