//
//  ChatInputView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/8/25.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // 텍스트 입력 필드
                HStack {
                    TextField("메시지를 입력하세요...", text: $messageText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                
                // 전송 버튼
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray60 : .deepBlue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }
}

//#Preview {
//    ChatInputView()
//}
