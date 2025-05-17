//
//  SignInViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine


final class SignInViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let appleSignInService: AppleSignInService
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var appleSignInService = PassthroughSubject<Void, Never>()
        var kakaoSigninTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSignIn = PassthroughSubject<Bool, Never>()
    }
    
    init(appleSignInService: AppleSignInService) {
        self.appleSignInService = appleSignInService
        transform()
    }
    
    func transform() {
        var IsSuccessAppleSignIn = PassthroughSubject<Void, Never>()
        
        input.appleSignInService
            .sink { [weak self] in
                self?.appleSignInService.signIn()
            }
            .store(in: &cancellables)
        
        appleSignInService.loginSuccess
            .sink { [weak self] in
                print($0)
                self?.output.isSignIn.send(true)
            }
            .store(in: &cancellables)
    }
}
