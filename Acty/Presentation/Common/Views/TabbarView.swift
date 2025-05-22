//
//  TabbarView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var diContainer: DIContainer
    var body: some View {
        TabView {
            SignInView(viewModel: diContainer.makeSignInViewModel())
                .tabItem {
                    Image(systemName: "star")
                }
        }
    }
}

#Preview {
    TabbarView()
}
