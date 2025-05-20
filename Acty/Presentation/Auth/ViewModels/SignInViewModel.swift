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
    private let kakaoSignInService: AuthServiceProtocol
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var appleSignInTapped = PassthroughSubject<Void, Never>()
        var kakaoSignInTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSignIn = PassthroughSubject<Bool, Never>()
        var errorMessage = PassthroughSubject<String, Never>()
    }
    
    init(appleSignInService: AuthServiceProtocol, kakaoSignInService: AuthServiceProtocol) {
        self.appleSignInService = appleSignInService
        self.kakaoSignInService = kakaoSignInService
        transform()
    }
    
    func transform() {
        var IsSuccessAppleSignIn = PassthroughSubject<Void, Never>()
        
        input.kakaoSignInTapped
            .sink { [weak self] in
                guard let self = self else { return }
                self.kakaoSignInService.signIn(
                    onSuccess: { result in
                        if let dto = result as? KakaoSignInRequestDTO {
                            print("카카오 로그인 성공: \(dto)")
                            self.output.isSignIn.send(true)
                        }
                    },
                    onError: { error in
                        print("카카오 로그인 오류: \(error)")
                        self.output.errorMessage.send(error)
                        self.output.isSignIn.send(false)
                    }
                )
            }
            .store(in: &cancellables)
        
        input.appleSignInTapped
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
                        self.output.errorMessage.send(error)
                        self.output.isSignIn.send(false)
                        print("Error: \(error)")
                    }
                )
            }
            .store(in: &cancellables)
    }
}
