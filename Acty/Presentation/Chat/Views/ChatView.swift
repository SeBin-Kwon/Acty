//
//  ChatView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/27/25.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    let userId: String
    @StateObject var viewModel: ChatViewModel
    
    @State private var messageText = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []
    @State private var showPhotoPicker = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    private let currentUserId: String = DIContainer.shared.currentUserId ?? ""
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.output.isLoading.value {
                ProgressView("채팅방 준비 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List {
                        // 페이지네이션 트리거 (상단)
                        if viewModel.output.hasMoreMessages.value {
                            pagingTriggerView
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                        
                        // 로딩 인디케이터 (더 로드 중일 때)
                        if viewModel.output.isLoadingMore.value {
                            loadingMoreView
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                        
                        ForEach(Array(viewModel.output.messages.enumerated()), id: \.element.chatId) { index, message in
                            
                            if shouldShowDateSeparator(for: message, at: index, in: viewModel.output.messages) {
                                DateSeparatorView(date: message.createdAtDate)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            }
                            
                            ChatMessageRow(message: message, currentUserId: currentUserId, shouldShowTime: shouldShowTime(for: message, at: index, in: viewModel.output.messages))
                                .id(message.chatId)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onChange(of: viewModel.output.messages) { messages in
                        if !viewModel.output.isLoadingMore.value {
                            scrollToBottom(proxy: proxy, messages: messages)
                        }
                    }
                    .onChange(of: selectedPhotos) { newPhotos in
                        handleSelectedPhotos(newPhotos)
                    }
                    .photosPicker(
                        isPresented: $showPhotoPicker,
                        selection: $selectedPhotos,
                        maxSelectionCount: 5,
                        matching: .images
                    )
                }
                
                if !selectedImageData.isEmpty {
                    ImagePreviewView(
                        selectedImages: selectedImageData,
                        onRemove: { index in
                            guard index >= 0 && index < selectedImageData.count else { return }
                            selectedImageData.remove(at: index)
                        }
                    )
                }
                
                ChatInputView(
                    messageText: $messageText,
                    onSend: sendMessage) {
                        showPhotoPicker = true
                    }
            }
        }
        .navigationTitle(viewModel.output.chatUserNickname ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.input.onAppear.send(())
        }
        .onDisappear {
            print("📱 ChatView onDisappear - Socket.IO 연결 해제")
            viewModel.input.onDisappear.send(())
        }
        .onReceive(viewModel.output.errorMessage) { errorMessage in
            self.errorMessage = errorMessage
            showErrorAlert = true
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인") { }
        } message: {
            Text(errorMessage)
        }
        .onReceive(viewModel.output.socketConnectionState) { state in
            print("🔗 Socket.IO 상태 UI 업데이트: \(state)")
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            print("📱 ChatView - 포그라운드 진입")
            viewModel.input.onForeground.send(())
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            print("📱 ChatView - 백그라운드 진입")
            viewModel.input.onBackground.send(())
        }
    }
    
    // MARK: - 페이지네이션 뷰들
    private var pagingTriggerView: some View {
        Color.clear
            .frame(height: 10)
            .onAppear {
                loadMoreMessages()
            }
    }
    
    private var loadingMoreView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("이전 메시지 불러오는 중...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
    
    private func loadMoreMessages() {
        guard !viewModel.output.isLoadingMore.value else { return }
        
        print("🔄 페이지네이션 트리거 - 이전 메시지 로드")
        viewModel.input.loadMoreMessages.send()
    }
    
    // 기존 메서드들...
    private func handleSelectedPhotos(_ photos: [PhotosPickerItem]) {
        guard !photos.isEmpty else { return }
        
        Task {
            var imageDataArray: [Data] = []
            
            for photo in photos {
                if let data = try? await photo.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                    imageDataArray.append(jpegData)
                }
            }
            
            await MainActor.run {
                selectedImageData = imageDataArray
                selectedPhotos = []
            }
        }
    }
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !content.isEmpty else { return }
        
        viewModel.input.sendMessage.send((content, selectedImageData))
        
        messageText = ""
        selectedImageData = []
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, messages: [ChatResponseDTO]) {
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.chatId, anchor: .bottom)
            }
        }
    }
    
    private func shouldShowDateSeparator(for message: ChatResponseDTO, at index: Int, in messages: [ChatResponseDTO]) -> Bool {
        guard index > 0 else { return true }
        
        let previousMessage = messages[index - 1]
        let currentDate = Calendar.current.startOfDay(for: message.createdAtDate)
        let previousDate = Calendar.current.startOfDay(for: previousMessage.createdAtDate)
        
        return currentDate != previousDate
    }
    
    private func shouldShowTime(for message: ChatResponseDTO, at index: Int, in messages: [ChatResponseDTO]) -> Bool {
        guard index < messages.count - 1 else { return true }
        
        let nextMessage = messages[index + 1]
        
        let currentMinute = message.displayTime
        let nextMinute = nextMessage.displayTime
        
        return currentMinute != nextMinute
    }
}

struct DateSeparatorView: View {
    let date: Date
    
    var body: some View {
        HStack {
            VStack {
                Divider()
            }
            
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
            
            VStack {
                Divider()
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter.string(from: date)
    }
}

struct ChatMessageRow: View {
    let message: ChatResponseDTO
    let currentUserId: String
    let shouldShowTime: Bool
    @State private var showImageViewer = false
    @State private var selectedImageIndex = 0
    
    private var isFromCurrentUser: Bool {
        let result = message.sender.userId == currentUserId
        print("💬 메시지 발신자 확인:")
        print("   - 메시지 발신자: \(message.sender.nick) (\(message.sender.userId))")
        print("   - 현재 사용자: \(currentUserId)")
        return result
    }
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 50)
                VStack(alignment: .trailing, spacing: 4) {
                    if let files = message.files, !files.isEmpty {
                        ChatImageLayoutView(
                            imageUrls: files,
                            isUploading: false
                        )
                    }
                    
                    if let content = message.content, !content.isEmpty {
                        Text(content)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.deepBlue)
                            .foregroundColor(.white)
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 18,
                                    bottomLeadingRadius: 18,
                                    bottomTrailingRadius: 4,
                                    topTrailingRadius: 18
                                )
                            )
                    }
                    
                    if shouldShowTime {
                        Text(message.displayTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    // 프로필 이미지
                    AsyncImage(url: URL(string: message.sender.profileImage ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Text(String(message.sender.nick.prefix(1)))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let files = message.files, !files.isEmpty {
                            ChatImageLayoutView(
                                imageUrls: files,
                                isUploading: false
                            )
                        }

                        if let content = message.content, !content.isEmpty {
                            Text(content)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                                .foregroundColor(.primary)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 4,
                                        bottomLeadingRadius: 18,
                                        bottomTrailingRadius: 18,
                                        topTrailingRadius: 18
                                    )
                                )
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                        }
                        
                        if shouldShowTime {
                            Text(message.displayTime)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    let diContainer = DIContainer.shared
    ChatView(userId: "test", viewModel: diContainer.makeChatViewModel(id: "test"))
}
