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
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.output.isLoading.value {
                ProgressView("채팅방 준비 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(Array(viewModel.output.messages.enumerated()), id: \.element.chatId) { index, message in
                            
                            if shouldShowDateSeparator(for: message, at: index, in: viewModel.output.messages) {
                                DateSeparatorView(date: message.createdAtDate)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            }
                            
                            ChatMessageRow(message: message, currentUserId: DIContainer.shared.currentUserId ?? "", shouldShowTime: shouldShowTime(for: message, at: index, in: viewModel.output.messages))
                                .id(message.chatId)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onChange(of: viewModel.output.messages) { messages in
                        scrollToBottom(proxy: proxy, messages: messages)
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
            print("Error: \(errorMessage)")
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
    
    private func handleSelectedPhotos(_ photos: [PhotosPickerItem]) {
            guard !photos.isEmpty else { return }
            
            Task {
                var imageDataArray: [Data] = []
                
                for photo in photos {
                    if let data = try? await photo.loadTransferable(type: Data.self) {
                        imageDataArray.append(data)
                    }
                }
                
                // ViewModel에 이미지 데이터 전달
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
        // 첫 번째 메시지는 항상 날짜 표시
        guard index > 0 else { return true }
        
        let previousMessage = messages[index - 1]
        let currentDate = Calendar.current.startOfDay(for: message.createdAtDate)
        let previousDate = Calendar.current.startOfDay(for: previousMessage.createdAtDate)
        
        // 이전 메시지와 다른 날짜면 구분선 표시
        return currentDate != previousDate
    }
    
    // 시간 표시 여부 결정 (같은 분의 마지막 메시지에만 표시)
    private func shouldShowTime(for message: ChatResponseDTO, at index: Int, in messages: [ChatResponseDTO]) -> Bool {
        // 마지막 메시지는 항상 시간 표시
        guard index < messages.count - 1 else { return true }
        
        let nextMessage = messages[index + 1]
        
        // 다음 메시지와 같은 분(HH:mm)인지 확인
        let currentMinute = message.displayTime
        let nextMinute = nextMessage.displayTime
        
        // 다음 메시지와 다른 분이면 시간 표시, 같은 분이면 시간 숨김
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
