//
//  SignUpView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import SwiftUI

struct SignUpView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var nickname: String = ""
    var body: some View {
        VStack {
            Text("email")
            TextField("이메일을 입력해주세요.", text: $email)
            Text("password")
            TextField("비밀번호를 입력해주세요.", text: $password)
            Text("nickname")
            TextField("닉네임을 입력해주세요.", text: $nickname)
            Button {
                Task {
                    do {
                        let result: SignUpRequest = try await NetworkManager.shared.fetchResults(api: .signUp(SignUpRequest(email: email, password: password, nick: nickname)))
                        // 결과 처리
                    } catch {
                        print("오류")
                        // 오류 처리
                    }
                }
                
            } label: {
                Text("회원가입 하기")
            }

        }
        .padding()
    }
}

#Preview {
    SignUpView()
}


