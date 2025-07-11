//
//  ChatView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/27/25.
//

import SwiftUI

struct ChatView: View {
    let userId: String
    @StateObject var viewModel: ChatViewModel
    
    @State private var messageText = ""
    
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.output.isLoading.value {
                ProgressView("채팅방 준비 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(viewModel.output.messages, id: \.chatId) { message in
                            ChatMessageRow(message: message, currentUserId: DIContainer.shared.currentUserId ?? "")
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
                }
                ChatInputView(
                    messageText: $messageText,
                    onSend: sendMessage
                )
            }
        }
        .navigationTitle(viewModel.output.chatUserNickname ?? "채팅")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.input.onAppear.send(())
        }
        .onReceive(viewModel.output.errorMessage) { errorMessage in
            print("Error: \(errorMessage)")
        }
    }
    
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        viewModel.input.sendMessage.send(content)
        messageText = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, messages: [ChatResponseDTO]) {
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.chatId, anchor: .bottom)
            }
        }
    }
}

struct ChatMessageRow: View {
    let message: ChatResponseDTO
    let currentUserId: String
    
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
                    Text(message.content ?? "")
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
                    
                    Text(message.displayTime)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
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
                        Text(message.content ?? "")
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
                        
                        Text(message.displayTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
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
