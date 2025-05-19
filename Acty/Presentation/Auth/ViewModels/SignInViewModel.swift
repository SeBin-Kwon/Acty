//
//  SignInViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine
import KakaoSDKUser

final class SignInViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let appleSignInService: AuthServiceProtocol
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var appleSignInService = PassthroughSubject<Void, Never>()
        var kakaoSigninTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSignIn = PassthroughSubject<Bool, Never>()
    }
    
    init(appleSignInService: AuthServiceProtocol) {
        self.appleSignInService = appleSignInService
        transform()
    }
    
    func transform() {
        var IsSuccessAppleSignIn = PassthroughSubject<Void, Never>()
        
        input.kakaoSigninTapped
            .sink { [weak self] in
                if (UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            print("loginWithKakaoTalk() success.")

                            // 성공 시 동작 구현
                            _ = oauthToken
                        }
                    }
                } else {
                    // 웹 로그인 추가
                    UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                        if let error = error {
                            print(error)
                        } else {
                            print("loginWithKakaoAccount() success.")
                            // 성공 시 동작 구현
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        input.appleSignInService
            .sink { [weak self] in
                guard let self else { return }
                self.appleSignInService.signIn(
                    onSuccess: { result in
                        if let dto = result as? AppleSignInRequestDTO {
                            print(dto)
                            self.output.isSignIn.send(true)
                        }
                    },
                    onError: { error in
                        print("Error: \(error)")
                    }
                )
            }
            .store(in: &cancellables)
    }
}
