//
//  AuthService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/20/25.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func signIn(with type: SignInType, email: String?, password: String?) async throws -> UserDTO
    func checkAuthenticationStatus() async -> Bool
    func signOut() async throws
    var isAuthenticated: PassthroughSubject<Bool, Never> { get set }
    func getCurrentUser() -> UserDTO?
    func getCurrentUserId() -> String?
}

final class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    private let tokenService: TokenServiceProtocol
    private let appleSignInService: SignInServiceProtocol
    private let kakaoSignInService: SignInServiceProtocol
    private let userDefaultsManager = UserDefaultsManager.shared
    private var cachedUser: UserDTO?
    var isAuthenticated = PassthroughSubject<Bool, Never>()
    
    init(
        networkManager: NetworkManager,
        tokenService: TokenServiceProtocol,
        appleSignInService: SignInServiceProtocol,
        kakaoSignInService: SignInServiceProtocol
    ) {
        self.networkManager = networkManager
        self.tokenService = tokenService
        self.appleSignInService = appleSignInService
        self.kakaoSignInService = kakaoSignInService
    }
    
    // MARK: - 통합 로그인 인터페이스
    func signIn(with type: SignInType, email: String? = nil, password: String? = nil) async throws -> UserDTO {
        print("통합 로그인 시작 - type: \(type)")
        
        switch type {
        case .email:
            return try await signInWithEmail(email: email, password: password)
        case .apple:
            return try await signInWithApple()
        case .kakao:
            return try await signInWithKakao()
        }
    }
    
    // MARK: - Private 로그인 구현
    private func signInWithEmail(email: String?, password: String?) async throws -> UserDTO {
        guard let email = email, let password = password else {
            throw AppError.invalidCredentials
        }
        
        let dto = EmailSignInRequestDTO(
            email: email,
            password: password,
            deviceToken: FCMService.shared.fcmToken
        )
        
        return try await performNetworkSignIn(endpoint: .emailSignIn(dto))
    }
    
    private func signInWithApple() async throws -> UserDTO {
        return try await withCheckedThrowingContinuation { continuation in
            appleSignInService.signIn(
                onSuccess: { result in
                    Task {
                        do {
                            guard var dto = result as? AppleSignInRequestDTO else {
                                continuation.resume(throwing: AppError.invalidResponse)
                                return
                            }
                            
                            dto = AppleSignInRequestDTO(
                                idToken: dto.idToken,
                                deviceToken: FCMService.shared.fcmToken,
                                nick: dto.nick
                            )
                            
                            let user = try await self.performNetworkSignIn(endpoint: .appleSignIn(dto))
                            continuation.resume(returning: user)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                },
                onError: { error in
                    continuation.resume(throwing: AppError.networkError(error))
                }
            )
        }
    }
    
    private func signInWithKakao() async throws -> UserDTO {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                kakaoSignInService.signIn(
                    onSuccess: { result in
                        Task {
                            do {
                                guard var dto = result as? KakaoSignInRequestDTO else {
                                    continuation.resume(throwing: AppError.invalidResponse)
                                    return
                                }
                                
                                dto = KakaoSignInRequestDTO(
                                    oauthToken: dto.oauthToken,
                                    deviceToken: FCMService.shared.fcmToken
                                )
                                
                                let user = try await self.performNetworkSignIn(endpoint: .kakaoSignIn(dto))
                                continuation.resume(returning: user)
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    },
                    onError: { error in
                        continuation.resume(throwing: AppError.networkError(error))
                    }
                )
            }
        }
    }
    
    // MARK: - 공통 네트워크 처리
    private func performNetworkSignIn(endpoint: AuthEndPoint) async throws -> UserDTO {
        let result: UserDTO = try await networkManager.fetchResults(api: endpoint)
        
        print("Access Token: \(result.accessToken)")
        print("Refresh Token: \(result.refreshToken)")
        print("로그인 성공, 토큰 저장 시작")
        
        try tokenService.saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        print("AuthService: 토큰 저장 완료")
        
        cachedUser = result
        saveCurrentUser(result)
        
        await MainActor.run {
            isAuthenticated.send(true)
        }
        
        return result
    }
    
    @MainActor
    func checkAuthenticationStatus() async -> Bool {
        print(#function)
        
        do {
            let accessToken = try tokenService.getAccessToken()
            print(#function, "액세스 토큰 발견: \(accessToken.prefix(10))...")
            
            let _: ProfileGetDTO = try await networkManager.fetchResults(api: AuthEndPoint.myProfileGet)
            isAuthenticated.send(true)
            return true
        } catch {
            print("액세스 토큰 없음 또는 만료: \(error)")
        }

        do {
            print("리프레시 토큰으로 갱신 시도")
            let newAccessToken = try await tokenService.refreshToken()
            print("토큰 갱신 성공: \(newAccessToken.prefix(10))...")
            isAuthenticated.send(true)
            return true
        } catch {
            print("토큰 갱신 실패: \(error)")
//            try? tokenService.deleteTokens()
            isAuthenticated.send(false)
            return false
        }
    }
    
    func signOut() async throws {
        print("로그아웃 시작")
        
        try tokenService.deleteTokens()
        clearCurrentUser()
        isAuthenticated.send(false)
        
        print("로그아웃 완료")
    }
    
    private func saveCurrentUser(_ user: UserDTO) {
        userDefaultsManager.save(user, forKey: UserDefaultsManager.Keys.currentUser)
        
        print("👤 현재 유저 정보 저장 완료:")
        print("   - userId: \(user.id)")
        print("   - nick: \(user.nick)")
        print("   - email: \(user.email)")
    }
    
    // MARK: - 현재 유저 조회
    func getCurrentUser() -> UserDTO? {
        
        if let cachedUser = cachedUser {
            return cachedUser
        }
        
        guard let user = userDefaultsManager.load(UserDTO.self, forKey: UserDefaultsManager.Keys.currentUser) else {
            print("⚠️ 저장된 현재 유저 정보 없음")
            return nil
        }
        
        cachedUser = user
        print("👤 현재 유저 정보 조회: \(user.nick)(\(user.id))")
        return user
    }
    
    func getCurrentUserId() -> String? {
        let userId = getCurrentUser()?.id
        print("👤 현재 유저 ID: \(userId ?? "nil")")
        return userId
    }
    
    private func clearCurrentUser() {
        userDefaultsManager.remove(forKey: UserDefaultsManager.Keys.currentUser)
        cachedUser = nil
        print("👤 현재 유저 정보 삭제 완료")
    }
}


struct ProfileGetDTO: Decodable {
    let userId: String
    let email: String
    let nick: String?
    let profileImage: String?
    let phoneNum: String?
    let introduction: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email, nick, profileImage, phoneNum, introduction
    }
}
