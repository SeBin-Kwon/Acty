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
        ScrollView {
            LazyVStack() {
                HStack {
                    Text("채팅방")
                        .font(.paperLogy(.title1))
                        .padding(20)
                        .wrapToButton {
                            navigationRouter.navigate(to: .chat(userId: "123"), in: .main)
                        }
                    Spacer()
                }
            }
        }
    }
}

//#Preview {
//    ChatListView()
//}
