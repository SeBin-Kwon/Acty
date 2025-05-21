//
//  DIContainer.swift
//  Acty
//
//  Created by Sebin Kwon on 5/21/25.
//

import Foundation

protocol DIContainerProtocol {
//    var authRepository: AuthRepositoryProtocol { get }
//    var networkManager: NetworkManager { get }
    var appleSignInService: AuthServiceProtocol { get }
    var kakaoSignInService: AuthServiceProtocol { get }
    
//    func makeSignInViewModel() -> SignInViewModel
    func makeSignUpViewModel() -> SignUpViewModel
}

final class AppDIContainer: DIContainerProtocol, ObservableObject {
    static let shared = AppDIContainer()
    
    let keychainManager: KeychainManager
//    let networkManager: NetworkManager
//    let authRepository: AuthRepositoryProtocol
    let appleSignInService: AuthServiceProtocol
    let kakaoSignInService: AuthServiceProtocol
    
    private init() {
        self.keychainManager = KeychainManager.shared
        
//        let tempNetworkManager = NetworkManager()
//        let authRepository = AuthRepository(networkManager: tempNetworkManager,
//                                          keychainManager: self.keychainManager)
//        tempNetworkManager.authRepository = authRepository
        
//        self.networkManager = tempNetworkManager
//        self.authRepository = authRepository
        self.appleSignInService = AppleSignInService()
        self.kakaoSignInService = KakaoSignInService()
    }
    
    // 팩토리 메서드 구현
//    func makeSignInViewModel() -> SignInViewModel {
//        return SignInViewModel(
//            authRepository: authRepository,
//            appleSignInService: appleSignInService,
//            kakaoSignInService: kakaoSignInService
//        )
//    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel()
    }
}
