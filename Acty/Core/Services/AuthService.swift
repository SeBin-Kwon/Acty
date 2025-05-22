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
}

final class AuthService: AuthServiceProtocol {
    private let networkManager: NetworkManager
    private let tokenService: TokenServiceProtocol
    
    var authStateDidChange = PassthroughSubject<Bool, Never>()

    
    init(networkManager: NetworkManager, tokenService: TokenServiceProtocol) {
        self.networkManager = networkManager
        self.tokenService = tokenService
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
        print("@@@@@@@@@@@@@@@@@@@ 네트워킹 직전")
        let result: UserDTO = try await networkManager.fetchResults(api: endpoint)
        
        print("로그인 성공, 토큰 저장 시작")
        print("Access Token: \(result.accessToken.prefix(10))...")
        print("Refresh Token: \(result.refreshToken.prefix(10))...")
        
        try tokenService.saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        
        print("AuthRepository: 토큰 저장 완료")
        
        authStateDidChange.send(true)
        
        return result
    }
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
