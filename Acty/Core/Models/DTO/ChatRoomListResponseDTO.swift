//
//  ChatRoomListResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/2/25.
//

import Foundation

struct ChatRoomListResponseDTO: Codable {
    let data: [ChatRoomResponseDTO]
}

struct ChatRoomResponseDTO: Codable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [SenderDTO]
    let lastChat: ChatResponseDTO?
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt, updatedAt, participants, lastChat
    }
}

extension ChatRoomResponseDTO {
    var opponentUser: SenderDTO? {
        return participants.first { $0.userId != DIContainer.shared.currentUserId }
        }
}

extension ChatRoomResponseDTO {
    static var mockData: [ChatRoomResponseDTO] {
        [
            ChatRoomResponseDTO(
                roomId: "66387304d5418c5e1e141862",
                createdAt: "2025-07-11T10:30:52.542Z",
                updatedAt: "2025-07-11T14:15:30.542Z",
                participants: [
                    SenderDTO(
                        userId: "65c9aa6932b0964405117d97",
                        nick: "김새싹",
                        name: "김새싹",
                        profileImage: "/data/profiles/1707716853682.png",
                        introduction: "안녕하세요!",
                        hashTags: ["iOS", "Swift"]
                    ),
                    SenderDTO(
                        userId: "current_user_id", // 현재 사용자
                        nick: "나",
                        name: "나",
                        profileImage: nil,
                        introduction: nil,
                        hashTags: nil
                    )
                ],
                lastChat: ChatResponseDTO(
                    chatId: "66386735e7696bd61fd5ef14",
                    roomId: "66387304d5418c5e1e141862",
                    content: "반갑습니다 :)",
                    createdAt: "2025-07-11T14:15:30.542Z",
                    updatedAt: "2025-07-11T14:15:30.542Z",
                    sender: SenderDTO(
                        userId: "65c9aa6932b0964405117d97",
                        nick: "김새싹",
                        name: "김새싹",
                        profileImage: "/data/profiles/1707716853682.png",
                        introduction: "안녕하세요!",
                        hashTags: ["iOS", "Swift"]
                    ),
                    files: ["/data/chats/image_1712739634962.png"]
                )
            ),
            ChatRoomResponseDTO(
                roomId: "66387304d5418c5e1e141863",
                createdAt: "2025-07-11T09:20:12.123Z",
                updatedAt: "2025-07-11T09:45:22.123Z",
                participants: [
                    SenderDTO(
                        userId: "65c9aa6932b0964405117d98",
                        nick: "박개발",
                        name: "박개발",
                        profileImage: nil,
                        introduction: "개발자입니다",
                        hashTags: ["React", "Node.js"]
                    ),
                    SenderDTO(
                        userId: "current_user_id",
                        nick: "나",
                        name: "나",
                        profileImage: nil,
                        introduction: nil,
                        hashTags: nil
                    )
                ],
                lastChat: ChatResponseDTO(
                    chatId: "66386735e7696bd61fd5ef15",
                    roomId: "66387304d5418c5e1e141863",
                    content: "오늘 점심 뭐 드세요?",
                    createdAt: "2025-07-11T09:45:22.123Z",
                    updatedAt: "2025-07-11T09:45:22.123Z",
                    sender: SenderDTO(
                        userId: "current_user_id",
                        nick: "나",
                        name: "나",
                        profileImage: nil,
                        introduction: nil,
                        hashTags: nil
                    ),
                    files: nil
                )
            ),
            ChatRoomResponseDTO(
                roomId: "66387304d5418c5e1e141864",
                createdAt: "2025-07-10T15:30:52.542Z",
                updatedAt: "2025-07-10T20:10:15.542Z",
                participants: [
                    SenderDTO(
                        userId: "65c9aa6932b0964405117d99",
                        nick: "이디자이너",
                        name: "이디자이너",
                        profileImage: "/data/profiles/designer.png",
                        introduction: "UI/UX 디자이너",
                        hashTags: ["Figma", "Design"]
                    ),
                    SenderDTO(
                        userId: "current_user_id",
                        nick: "나",
                        name: "나",
                        profileImage: nil,
                        introduction: nil,
                        hashTags: nil
                    )
                ],
                lastChat: ChatResponseDTO(
                    chatId: "66386735e7696bd61fd5ef16",
                    roomId: "66387304d5418c5e1e141864",
                    content: "내일 회의 시간 괜찮으신가요?",
                    createdAt: "2025-07-10T20:10:15.542Z",
                    updatedAt: "2025-07-10T20:10:15.542Z",
                    sender: SenderDTO(
                        userId: "65c9aa6932b0964405117d99",
                        nick: "이디자이너",
                        name: "이디자이너",
                        profileImage: "/data/profiles/designer.png",
                        introduction: "UI/UX 디자이너",
                        hashTags: ["Figma", "Design"]
                    ),
                    files: nil
                )
            )
        ]
    }
}
