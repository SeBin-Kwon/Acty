//
//  TokenService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/21/25.
//

import Foundation

protocol TokenServiceProtocol {
    func refreshToken() async throws -> String
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() throws -> String
    func getRefreshToken() throws -> String
    func deleteTokens() throws
}

final class TokenService: TokenServiceProtocol {
    private let networkManager: NetworkManager
    private let keychainManager: KeychainManager
    
    private enum TokenType {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    init(keychainManager: KeychainManager = .shared) {
        self.networkManager = NetworkManager()
        self.keychainManager = keychainManager
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
}
