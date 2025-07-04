//
//  SignInView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: SignInViewModel
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("로그인")
                    .font(.paperLogy(.body1))
                TextField("아이디", text: $viewModel.input.email)
                    .padding(10)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.accent, lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                SecureField("비밀번호", text: $viewModel.input.password)
                    .padding(10)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.accent, lineWidth: 1)
                    )
                loginButton
                appleButton
                kakaoButton
                Button("회원가입") {
                    navigationRouter.navigate(to: .signUp, in: .auth)
               }
            }
            .padding()
        }
        .onReceive(viewModel.output.isSignIn) { value in
            if value {
                navigateToHome = true
            }
        }
    }
    
    private var loginButton: some View {
        Text("로그인")
            .font(.pretendard(.title(.bold)))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.deepBlue)
            .clipShape(.rect(cornerRadius: 10))
            .wrapToButton {
                viewModel.input.signInTapped.send(.email)
            }
    }
    
    private var kakaoButton: some View {
        Button {
            viewModel.input.signInTapped.send(.kakao)
        } label: {
            Text("카카오톡 로그인")
        }
    }
    
    private var appleButton: some View {
        SignInWithAppleButton(
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(_):
                    print("Authorization successful.")
                    break
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .frame(width : UIScreen.main.bounds.width * 0.9, height:50)
        .onTapGesture {
            viewModel.input.signInTapped.send(.apple)
        }
        .cornerRadius(5)

    }
}


#if DEBUG
#Preview {
    let diContainer = DIContainer.shared
    SignInView(viewModel: diContainer.makeSignInViewModel())
}
#endif
