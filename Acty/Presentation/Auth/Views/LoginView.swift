//
//  LoginView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Login")
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    LoginView()
}
#endif
