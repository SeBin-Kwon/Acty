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
    
    private enum TokenType {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    init(networkManager: NetworkManager = .shared,
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
        try saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
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
        try keychainManager.saveToken(token: accessToken, for: TokenType.accessToken)
        try keychainManager.saveToken(token: refreshToken, for: TokenType.refreshToken)
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
