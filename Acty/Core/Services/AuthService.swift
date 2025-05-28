//
//  AuthService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/20/25.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    func signIn(with dto: Any) async throws -> UserDTO
    func checkAuthenticationStatus() async -> Bool
    func signOut() async throws
    var isAuthenticated: PassthroughSubject<Bool, Never> { get set }
}

final class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    private let tokenService: TokenServiceProtocol
    
    var isAuthenticated = PassthroughSubject<Bool, Never>()
    
    init(networkManager: NetworkManager, tokenService: TokenServiceProtocol) {
        self.networkManager = networkManager
        self.tokenService = tokenService
    }
    
    func signIn(with dto: Any) async throws -> UserDTO {
        print(#function)
        let endpoint: EndPoint
        
        switch dto {
        case let emailDTO as EmailSignInRequestDTO:
            endpoint = .emailSignIn(emailDTO)
        case let appleDTO as AppleSignInRequestDTO:
            endpoint = .appleSignIn(appleDTO)
        case let kakaoDTO as KakaoSignInRequestDTO:
            endpoint = .kakaoSignIn(kakaoDTO)
        default:
            throw NSError(domain: "Invalid DTO type", code: 400)
        }
        print("@@@@@@@@@@@@@@@@@@@ 네트워킹 직전")
        let result: UserDTO = try await networkManager.fetchResults(api: endpoint)
        
        print("로그인 성공, 토큰 저장 시작")
        print("Access Token: \(result.accessToken.prefix(10))...")
        print("Refresh Token: \(result.refreshToken.prefix(10))...")
        
        try tokenService.saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        
        print("AuthRepository: 토큰 저장 완료")
        
        isAuthenticated.send(true)
        
        return result
    }
    
    func checkAuthenticationStatus() async -> Bool {
        print(#function)
        print("인증 상태 체크 시작")
        do {
            let accessToken = try tokenService.getAccessToken()
            print("액세스 토큰 발견: \(accessToken.prefix(10))...")
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
            try? tokenService.deleteTokens()
            isAuthenticated.send(false)
            return false
        }
    }
    
    func signOut() async throws {
        print("로그아웃 시작")
        
        try tokenService.deleteTokens()
        isAuthenticated.send(false)
        
        print("로그아웃 완료")
    }
    
}
