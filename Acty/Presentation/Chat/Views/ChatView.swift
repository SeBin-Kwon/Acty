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
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: "1", text: "안녕하세요! 반가워요 😊", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(id: "2", text: "안녕하세요! 잘 지내시나요?", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3500)),
        ChatMessage(id: "3", text: "네, 잘 지내고 있어요. 오늘 날씨가 정말 좋네요!", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3400)),
        ChatMessage(id: "4", text: "정말요? 저도 산책하러 나가고 싶어지네요", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3300)),
        ChatMessage(id: "5", text: "좋은 생각이에요! 함께 가실래요?", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3200)),
    ]
    

    var body: some View {
        VStack(spacing: 0) {
            // 채팅 메시지 리스트
            ScrollViewReader { proxy in
                List {
                    ForEach(messages) { message in
                        ChatMessageRow(message: message)
                            .id(message.id)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            ChatInputView(messageText: $messageText, onSend: sendMessage)
        }
        .navigationTitle("닉네임")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.input.onAppear.send(())
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isFromCurrentUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let isFromCurrentUser: Bool
    let timestamp: Date
}

struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
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
                    
                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    // 프로필 이미지
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("😊")
                                .font(.system(size: 16))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(message.text)
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
                        
                        Text(timeString(from: message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                }
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    let diContainer = DIContainer.shared
    ChatView(userId: "test", viewModel: diContainer.makeChatViewModel(id: "est"))
}
