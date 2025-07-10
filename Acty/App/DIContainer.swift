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
//    var appleSignInService: SignInServiceProtocol { get }
//    var kakaoSignInService: SignInServiceProtocol { get }
//    
//    func makeSignInViewModel() -> SignInViewModel
//    func makeSignUpViewModel() -> SignUpViewModel
//}

final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    
    let keychainManager: KeychainManager
    let networkManager: NetworkManager
    let authService: AuthServiceProtocol
    let tokenService: TokenServiceProtocol
    let appleSignInService: SignInServiceProtocol
    let kakaoSignInService: SignInServiceProtocol
    let activityService: ActivityServiceProtocol
    let paymentService: PaymentServiceProtocol
    let orderService: OrderServiceProtocol
    let chatService: ChatServiceProtocol
    let chatRepository: ChatRepositoryProtocol
    let coreDataManaager: CoreDataManagerProtocol
    
    private init() {
        self.keychainManager = KeychainManager.shared
        self.tokenService = TokenService(keychainManager: keychainManager)
        self.networkManager = NetworkManager(tokenService: tokenService)
        self.appleSignInService = AppleSignInService()
        self.kakaoSignInService = KakaoSignInService()
        self.authService = AuthService(networkManager: networkManager, tokenService: tokenService)
        self.activityService = ActivityService(networkManager: networkManager)
        self.paymentService = PaymentService(networkManager: networkManager)
        self.orderService = OrderService(networkManager: networkManager)
        self.chatService = ChatService(networkManager: networkManager)
        self.coreDataManaager = CoreDataManager.shared
        self.chatRepository = ChatRepository(chatService: chatService, coreDataManager: coreDataManaager)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(
            appleSignInService: appleSignInService,
            kakaoSignInService: kakaoSignInService,
            authService: authService
        )
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel()
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(activityService: activityService)
    }
    
    func makeDetailViewModel() -> DetailViewModel {
        return DetailViewModel(activityService: activityService)
    }
    
    func makePaymentViewModel() -> PaymentViewModel {
        return PaymentViewModel(paymentService: paymentService, orderService: orderService)
    }
    
    func makeChatViewModel(id: String) -> ChatViewModel {
        return ChatViewModel(chatService: chatService, chatRepository: chatRepository, userId: id)
    }
}
