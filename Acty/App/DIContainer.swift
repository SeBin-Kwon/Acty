//
//  DIContainer.swift
//  Acty
//
//  Created by Sebin Kwon on 5/21/25.
//

import Foundation

//protocol DIContainerProtocol {
//    var authRepository: AuthRepositoryProtocol { get }
//    var networkManager: NetworkManager { get }
//    var tokenService: TokenServiceProtocol { get }
//    var appleSignInService: AuthServiceProtocol { get }
//    var kakaoSignInService: AuthServiceProtocol { get }
//    
//    func makeSignInViewModel() -> SignInViewModel
//    func makeSignUpViewModel() -> SignUpViewModel
//}

final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    
    let keychainManager: KeychainManager
    let networkManager: NetworkManager
    let authRepository: AuthRepositoryProtocol
    let tokenService: TokenServiceProtocol
    let appleSignInService: AuthServiceProtocol
    let kakaoSignInService: AuthServiceProtocol
    
    private init() {
        self.keychainManager = KeychainManager.shared
        self.tokenService = TokenService(keychainManager: keychainManager)
        self.networkManager = NetworkManager(tokenService: tokenService)
        self.appleSignInService = AppleSignInService()
        self.kakaoSignInService = KakaoSignInService()
        self.authRepository = AuthRepository(networkManager: networkManager, tokenService: tokenService)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(
            appleSignInService: appleSignInService,
            kakaoSignInService: kakaoSignInService,
            authReportository: authRepository
        )
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel()
    }
}
