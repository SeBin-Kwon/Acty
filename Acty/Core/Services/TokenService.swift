//
//  TokenService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/21/25.
//

import Foundation

protocol TokenServiceProtocol: Sendable {
    func refreshToken() async throws -> String
    func saveTokens(accessToken: String, refreshToken: String) throws
    func getAccessToken() throws -> String
    func getRefreshToken() throws -> String
    func deleteTokens() throws
}

final class TokenService: TokenServiceProtocol {
    private weak var networkManager: NetworkManager?
    private let keychainManager: KeychainManager
    
    private var cachedAccessToken: String?
    private var tokenCacheTime: Date?
    private let cacheValidDuration: TimeInterval = 60 * 5
    
    private var refreshTask: Task<String, Error>?
    private let refreshLock = NSLock()
    
    private enum TokenType {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }
    
    init(networkManager: NetworkManager, keychainManager: KeychainManager = .shared) {
        self.networkManager = networkManager
        self.keychainManager = keychainManager
    }
    
    func setNetworkManager(_ networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func refreshToken() async throws -> String {
        
        guard let networkManager = networkManager else {
            throw AppError.networkError("NetworkManager가 설정되지 않았습니다")
        }
        
        refreshLock.lock()
        defer { refreshLock.unlock() }
        
        // 🚩 이미 진행 중인 토큰 갱신이 있다면 해당 결과를 반환
        if let existingTask = refreshTask {
            print("🔄 진행 중인 토큰 갱신 대기...")
            return try await existingTask.value
        }
        
        let task = Task<String, Error> {
            do {
                print("🔄 토큰 갱신 시작")
                let refreshToken = try getRefreshToken()
                print("🔑 사용할 Refresh Token: \(refreshToken)")
                let endpoint: AuthEndPoint = .refreshToken(refreshToken)
                print("📋 최종 헤더: \(endpoint.headers)")
                let result: RefreshTokenResponse = try await networkManager.fetchResults(api: endpoint)
                try saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
                print("✅ 토큰 갱신 완료")
                return result.accessToken
            } catch {
                print("❌ 토큰 갱신 실패: \(error)")
                if let afError = error.asAFError,
                   case .responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)) = afError {
                    if statusCode == 418 { // 리프레시 토큰 만료
                        try? deleteTokens()
                        print("🗑 리프레시 토큰 만료로 토큰 삭제")
                    }
                    // 444나 다른 에러는 토큰 삭제 안 함
                }
                throw error
            }
        }
        
        refreshTask = task
        
        do {
            let result = try await task.value
            refreshTask = nil // 🚩 작업 완료 후 정리
            return result
        } catch {
            refreshTask = nil // 🚩 실패 시에도 정리
            throw error
        }
        
        //        let refreshToken = try getRefreshToken()
        //        let endpoint: AuthEndPoint = .refreshToken(refreshToken)
        //        let result: RefreshTokenResponse = try await networkManager.fetchResults(api: endpoint)
        //
        //        try saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        //        return result.accessToken
    }
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        print("키체인에 토큰 저장 시도")
        
        try keychainManager.saveToken(token: accessToken, for: TokenType.accessToken)
        try keychainManager.saveToken(token: refreshToken, for: TokenType.refreshToken)
        
        do {
            let savedAccessToken = try keychainManager.getToken(for: TokenType.accessToken)
            let savedRefreshToken = try keychainManager.getToken(for: TokenType.refreshToken)
            cachedAccessToken = accessToken
            print("저장된 토큰 확인:")
            print("Access Token 저장됨: \(savedAccessToken.prefix(10))...")
            print("Refresh Token 저장됨: \(savedRefreshToken.prefix(10))...")
        } catch {
            print("토큰 검증 실패: \(error)")
            throw error
        }
    }
    
    func getAccessToken() throws -> String {
        
        if let cached = cachedAccessToken,
           let cacheTime = tokenCacheTime,
           Date().timeIntervalSince(cacheTime) < cacheValidDuration {
            return cached
        }
        
        let token = try keychainManager.getToken(for: TokenType.accessToken)
        cachedAccessToken = token
        tokenCacheTime = Date()
        
        return token
    }
    
    func getRefreshToken() throws -> String {
        return try keychainManager.getToken(for: TokenType.refreshToken)
    }
    
    func deleteTokens() throws {
        try keychainManager.deleteToken(for: TokenType.accessToken)
        try keychainManager.deleteToken(for: TokenType.refreshToken)
        cachedAccessToken = nil
        tokenCacheTime = nil
    }
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
