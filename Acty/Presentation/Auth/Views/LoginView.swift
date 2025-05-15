//
//  LoginView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Login")
                AppleSigninButton()
                NavigationLink("SignUp") {
                    SignUpView()
                }
            }
            .padding()
        }
    }
}

struct AppleSigninButton : View{
    
    var body: some View{
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("Authorization successful.")
                    break
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .frame(width : UIScreen.main.bounds.width * 0.9, height:50)
        .onTapGesture {
            print("")
        }
        .cornerRadius(5)
    }
}

#if DEBUG
#Preview {
    LoginView()
}
#endif
