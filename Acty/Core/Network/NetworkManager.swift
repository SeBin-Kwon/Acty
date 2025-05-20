//
//  NetworkManager.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    var authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func fetchResults<T: Decodable>(api: EndPoint) async throws -> T {
        do {
            return try await performRequest(api: api)
        } catch {
            if let afError = error as? AFError,
               let response = afError.responseCode,
               response == 401 {
                if case .refreshToken = api {
                    throw error
                }
                do {
                    _ = try await authRepository.refreshToken()
                    return try await performRequest(api: api)
                } catch {
                    try? authRepository.deleteTokens()
                    throw error
                }
            }
            throw error
        }
    }
    
    private func performRequest<T: Decodable>(api: EndPoint) async throws -> T {
        
        var headers = api.headers
        
        if api.requiresAuth {
            do {
                let token = try authRepository.getAccessToken()
                headers.add(name: "Authorization", value: "Bearer \(token)")
            } catch {
                throw NSError(domain: "인증 정보가 없습니다", code: 401)
            }
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(api.endPoint,
                       method: api.method,
                       parameters: api.parameters,
                       encoding: api.encoding,
                       headers: api.headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    continuation.resume(returning: result)
                case .failure(let error):
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
