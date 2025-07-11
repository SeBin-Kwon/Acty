//
//  ChatListView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/29/25.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: ChatListViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 채팅방 목록
                chatRoomsListView
            }
            .navigationTitle("채팅")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    newChatButton
                }
            }
            .onAppear {
                viewModel.input.onAppear.send(())
            }
            .refreshable {
                viewModel.input.refreshTriggered.send(())
            }
            .onReceive(viewModel.output.errorMessage) { errorMessage in
                print("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - 채팅방 목록 뷰
    private var chatRoomsListView: some View {
        Group {
            if viewModel.output.chatRooms.isEmpty && !viewModel.output.isLoading.value {
                emptyStateView
            } else {
                List {
                    ForEach(viewModel.output.chatRooms, id: \.roomId) { chatRoom in
                        ChatRoomRow(chatRoom: chatRoom) {
                            navigationRouter.navigate(to: .chat(userId: chatRoom.opponentUser?.userId ?? ""), in: .main)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .opacity(0.5)
            
            VStack(spacing: 8) {
                Text("아직 채팅방이 없어요")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("새로운 채팅을 시작해보세요!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                // 새 채팅 시작 액션
                viewModel.input.newChatButtonTapped.send(())
            } label: {
                HStack {
                    Image(systemName: "plus.message")
                    Text("새 채팅 시작")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.deepBlue)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - 새 채팅 버튼
    private var newChatButton: some View {
        Button {
            viewModel.input.newChatButtonTapped.send(())
        } label: {
            Image(systemName: "square.and.pencil")
                .font(.title3)
                .foregroundColor(.deepBlue)
        }
    }
}

// MARK: - 채팅방 행 뷰
struct ChatRoomRow: View {
    let chatRoom: ChatRoomResponseDTO
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 프로필 이미지
                profileImageView
                
                // 채팅방 정보
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chatRoomTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
//                        Text(formattedTime)
//                            .font(.caption)
//                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(lastMessageText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 프로필 이미지
    private var profileImageView: some View {
        Group {
            if let participant = chatRoom.opponentUser,
               let profileImageURL = participant.profileImage,
               !profileImageURL.isEmpty {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(participant.nick.prefix(1)))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        )
                }
            } else {
                Circle()
                    .fill(.deepBlue.opacity(0.8))
                    .overlay(
                        Text(String(chatRoomTitle.prefix(1)))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(width: 50, height: 50)
        .clipShape(Circle())
    }
    
    // MARK: - 계산된 속성들
    private var chatRoomTitle: String {
        if let participant = chatRoom.opponentUser {
            return participant.nick
        }
        return "알 수 없는 사용자"
    }
    
    private var lastMessageText: String {
        if let lastMessage = chatRoom.lastChat?.content, !lastMessage.isEmpty {
            return lastMessage
        }
        return "메시지가 없습니다"
    }
    
//    private var formattedTime: String {
//        guard let lastChatTime = chatRoom.lastChat?.createdAt else {
//            return ""
//        }
//        
//        let formatter = ISO8601DateFormatter()
//        guard let date = formatter.date(from: lastChatTime) else {
//            return ""
//        }
//        
//        let now = Date()
//        let calendar = Calendar.current
//        
//        if calendar.isToday(date) {
//            let timeFormatter = DateFormatter()
//            timeFormatter.timeStyle = .short
//            return timeFormatter.string(from: date)
//        } else if calendar.isYesterday(date) {
//            return "어제"
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "M/d"
//            return dateFormatter.string(from: date)
//        }
//    }
}

//#Preview {
//    let diContainer = DIContainer.shared
//    ChatListView(viewModel: diContainer.makeChatListViewModel())
//        .environmentObject(NavigationRouter())
//}
