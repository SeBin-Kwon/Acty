//
//  AuthRepository.swift
//  Acty
//
//  Created by Sebin Kwon on 5/20/25.
//

import Foundation
import Combine

protocol AuthRepositoryProtocol {
    func signIn(with dto: Any) async throws -> UserDTO
    func refreshToken() async throws -> String
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() throws -> String
    func getRefreshToken() throws -> String
    func deleteTokens() throws
    func isLoggedIn() -> Bool
}

final class AuthRepository: AuthRepositoryProtocol {
    private let networkManager: NetworkManager
    private let keychainManager: KeychainManager

    var authStateDidChange = PassthroughSubject<Bool, Never>()
    
    private enum TokenType {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    init(networkManager: NetworkManager,
         keychainManager: KeychainManager = .shared) {
        self.networkManager = networkManager
        self.keychainManager = keychainManager
    }
    
    func signIn(with dto: Any) async throws -> UserDTO {
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
        
        let result: UserDTO = try await networkManager.fetchResults(api: endpoint)
        
        print("로그인 성공, 토큰 저장 시작")
        print("Access Token: \(result.accessToken.prefix(10))...")
        print("Refresh Token: \(result.refreshToken.prefix(10))...")
        
        try saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        
        print("AuthRepository: 토큰 저장 완료")
        
        authStateDidChange.send(true)
        
        return result
    }
    
    func refreshToken() async throws -> String {
        let refreshToken = try getRefreshToken()
        let endpoint: EndPoint = .refreshToken(refreshToken)
        let result: RefreshTokenResponse = try await networkManager.fetchResults(api: endpoint)
        
        try saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        return result.accessToken
    }
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        print("키체인에 토큰 저장 시도")
                
        try keychainManager.saveToken(token: accessToken, for: TokenType.accessToken)
        try keychainManager.saveToken(token: refreshToken, for: TokenType.refreshToken)
        
        // 저장 후 검증
        do {
            let savedAccessToken = try keychainManager.getToken(for: TokenType.accessToken)
            let savedRefreshToken = try keychainManager.getToken(for: TokenType.refreshToken)
            
            print("저장된 토큰 확인:")
            print("Access Token 저장됨: \(savedAccessToken.prefix(10))...")
            print("Refresh Token 저장됨: \(savedRefreshToken.prefix(10))...")
        } catch {
            print("토큰 검증 실패: \(error)")
            throw error
        }
    }
    
    func getAccessToken() throws -> String {
        return try keychainManager.getToken(for: TokenType.accessToken)
    }
    
    func getRefreshToken() throws -> String {
        return try keychainManager.getToken(for: TokenType.refreshToken)
    }
    
    func deleteTokens() throws {
        try keychainManager.deleteToken(for: TokenType.accessToken)
        try keychainManager.deleteToken(for: TokenType.refreshToken)
    }
    
    func isLoggedIn() -> Bool {
        do {
            _ = try getAccessToken()
            return true
        } catch {
            return false
        }
    }
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
