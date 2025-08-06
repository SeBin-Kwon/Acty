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
    private lazy var _currentUser: UserDTO? = authService.getCurrentUser()
    
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
    let socketIOChatService: SocketIOChatServiceProtocol
    let bannerService: BannerServiceProtocol
    let pushNotificationService: PushNotificationServiceProtocol
    
    private init() {
        self.keychainManager = KeychainManager.shared
        let tempNetworkManager = NetworkManager()
        self.tokenService = TokenService(networkManager: tempNetworkManager, keychainManager: keychainManager)
        self.networkManager = NetworkManager(tokenService: tokenService)
        (self.tokenService as? TokenService)?.setNetworkManager(networkManager)
        self.appleSignInService = AppleSignInService()
        self.kakaoSignInService = KakaoSignInService()
        self.authService = AuthService(networkManager: networkManager, tokenService: tokenService, appleSignInService: appleSignInService, kakaoSignInService: kakaoSignInService)
        self.activityService = ActivityService(networkManager: networkManager)
        self.paymentService = PaymentService(networkManager: networkManager)
        self.orderService = OrderService(networkManager: networkManager)
        self.chatService = ChatService(networkManager: networkManager)
        self.coreDataManaager = CoreDataManager.shared
        self.socketIOChatService = SocketIOChatService(tokenService: tokenService)
        self.chatRepository = ChatRepository(chatService: chatService, coreDataManager: coreDataManaager, socketIOChatService: socketIOChatService)
        self.bannerService = BannerService(networkManager: networkManager)
        self.pushNotificationService = PushNotificationService(networkManager: networkManager)
    }
    
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(authService: authService)
    }
    
    func makeSignUpViewModel() -> SignUpViewModel {
        return SignUpViewModel()
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(activityService: activityService, bannerService: bannerService)
    }
    
    func makeDetailViewModel() -> DetailViewModel {
        return DetailViewModel(activityService: activityService)
    }
    
    func makePaymentViewModel() -> PaymentViewModel {
        return PaymentViewModel(paymentService: paymentService, orderService: orderService)
    }
    
    func makeChatViewModel(id: String) -> ChatViewModel {
        return ChatViewModel(chatService: chatService, chatRepository: chatRepository, socketIOChatService: socketIOChatService, pushNotificationService: pushNotificationService, userId: id)
    }
    
    func makeChatListViewModel() -> ChatListViewModel {
        return ChatListViewModel(chatRepository: chatRepository)
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel(activityService: activityService)
    }
}

extension DIContainer {
    var currentUser: UserDTO? {
            return _currentUser
        }
        
    var currentUserId: String? {
        return _currentUser?.id
    }
}
