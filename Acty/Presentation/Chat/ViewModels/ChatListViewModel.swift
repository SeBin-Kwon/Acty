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
    
    private let chatRepository: ChatRepositoryProtocol
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
        var refreshTriggered = PassthroughSubject<Void, Never>()
        var newChatButtonTapped = PassthroughSubject<Void, Never>()
        var searchTextChanged = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        var chatRooms = [ChatRoomResponseDTO]()
        var isLoading = CurrentValueSubject<Bool, Never>(false)
        var errorMessage = PassthroughSubject<String, Never>()
        var showNewChatSheet = PassthroughSubject<Bool, Never>()
        var navigateToChat = PassthroughSubject<String, Never>() // roomId
        var deleteAllSuccess = PassthroughSubject<Void, Never>()
    }
    
    init(chatRepository: ChatRepositoryProtocol) {
        self.chatRepository = chatRepository
        transform()
    }
    
    func transform() {
        // 화면 진입 시 채팅방 목록 로드
        input.onAppear
            .sink { [weak self] in
                self?.loadChatRooms()
            }
            .store(in: &cancellables)
        
        // 새로고침
        input.refreshTriggered
            .sink { [weak self] in
                self?.loadChatRooms(forceRefresh: true)
            }
            .store(in: &cancellables)
        
        // 새 채팅 버튼 탭
//        input.newChatButtonTapped
//            .sink { [weak self] in
//                self?.output.showNewChatSheet.send(true)
//            }
//            .store(in: &cancellables)
        
        // 검색어 변경
//        input.searchTextChanged
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .sink { [weak self] searchText in
//                self?.filterChatRooms(with: searchText)
//            }
//            .store(in: &cancellables)
        
//        input.deleteAllChatRooms
//            .sink { [weak self] in
//                self?.deleteAllChatRooms()
//            }
//            .store(in: &cancellables)
    }
    
    // MARK: - 채팅방 목록 로드
    private func loadChatRooms(forceRefresh: Bool = false) {
        guard !output.isLoading.value else { return } // 이미 로딩 중이면 중복 방지
        
        output.isLoading.send(true)
        
        Task {
            do {
                let allChatRooms = try await chatRepository.getChatRoomsList()
                
                let chatRooms = allChatRooms.filter { chatRoom in
                    return chatRoom.lastChat != nil  // 메시지가 있는 채팅방만
                }
                
                await MainActor.run {
                    self.output.chatRooms = chatRooms.sorted { room1, room2 in
                        // 마지막 메시지 시간순으로 정렬
                        let date1 = self.parseDate(room1.lastChat?.createdAt) ?? Date.distantPast
                        let date2 = self.parseDate(room2.lastChat?.createdAt) ?? Date.distantPast
                        return date1 > date2
                    }
                    self.output.isLoading.send(false)
                    print("채팅방 목록 로드 완료: \(chatRooms.count)개")
                    
                }
                
            } catch {
                await MainActor.run {
                    self.output.isLoading.send(false)
                    let appError = (error as? AppError) ?? AppError.networkError("채팅방 목록 로드 실패")
                    self.output.errorMessage.send(appError.localizedDescription)
                }
            }
        }
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
