//
//  SignInView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel(appleSignInService: AppleSignInService())
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Login")
                appleButton
                NavigationLink("SignUp") {
                    SignUpView()
                }
                NavigationLink(destination: HomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .padding()
        }
        .onReceive(viewModel.output.isSignIn) { _ in
            navigateToHome = true
        }
    }
    
    private var appleButton: some View {
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
            viewModel.input.appleSignInService.send(())
        }
        .cornerRadius(5)

    }
}


#if DEBUG
#Preview {
    SignInView()
}
#endif
