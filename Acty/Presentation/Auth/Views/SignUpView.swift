//
//  SignUpView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            Text("email")
            HStack {
                TextField("이메일을 입력해주세요.", text: $viewModel.input.email)
                Button {
                    print("sd")
                } label: {
                    Text("이메일 유효성 확인")
                }

            }
            Text("password")
            TextField("비밀번호를 입력해주세요.", text: $viewModel.input.password)
            Text("nickname")
            TextField("닉네임을 입력해주세요.", text: $viewModel.input.nickname)
            Button {
                viewModel.input.signUpButtonTapped.send(())
            } label: {
                Text("회원가입 하기")
            }

        }
        .padding()
    }
}

#if DEBUG
//#Preview {
//    SignUpView()
//}
#endif

struct SignUpResult: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
