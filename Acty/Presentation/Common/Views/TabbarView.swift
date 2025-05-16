//
//  TabbarView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct TabbarView: View {
    var body: some View {
        TabView {
            SignInView()
                .tabItem {
                    Image(systemName: "star")
                }
        }
    }
}

#Preview {
    TabbarView()
}
