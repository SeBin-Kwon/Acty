//
//  LoginViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine


final class LoginViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
//    @Published var givenName: String = ""
//    @Published var errorMessage: String = ""
//    @Published var oauthUserData = OAuthUserData()
    
    private let appleLoginService: AppleLoginService
    
    struct Input {
        var appleLoginTapped = PassthroughSubject<Void, Never>()
        var kakaoLoginTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        
    }
    
    init(appleLoginService: AppleLoginService) {
        self.appleLoginService = appleLoginService
        transform()
    }
    
    func transform() {
        input.appleLoginTapped
            .sink { [weak self] in
                self?.appleLoginService.signIn()
            }
            .store(in: &cancellables)
    }
}
