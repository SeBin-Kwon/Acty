//
//  NetworkManager.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    private let tokenService: TokenServiceProtocol
    
    init(tokenService: TokenServiceProtocol) {
        self.tokenService = tokenService
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        if let url = request.url?.absoluteString,
           !url.contains("login") && !url.contains("refresh") {
            do {
                let token = try tokenService.getAccessToken()
                request.headers.add(name: "Authorization", value: "Bearer \(token)")
                completion(.success(request))
            } catch {
                completion(.success(request))
            }
        } else {
            completion(.success(request))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        if let url = request.request?.url?.absoluteString, url.contains("refresh") {
            completion(.doNotRetry)
            return
        }
        
        Task {
            do {
                _ = try await tokenService.refreshToken()
                completion(.retry)
            } catch {
                try? tokenService.deleteTokens()
                completion(.doNotRetry)
            }
        }
    }
}

final class NetworkManager {
    private let session: Session
    var tokenService: TokenServiceProtocol?
    
    init() {
        self.tokenService = nil
        self.session = Session()
    }
    
    init(tokenService: TokenServiceProtocol) {
        self.tokenService = tokenService
        let interceptor = AuthInterceptor(tokenService: tokenService)
        self.session = Session(interceptor: interceptor)
    }
    
    func fetchResults<T: Decodable>(api: EndPoint) async throws -> T {
        
        var headers = api.headers
        
        if api.requiresAuth, let tokenService = self.tokenService {
            do {
                let token = try tokenService.getAccessToken()
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
                       headers: headers)
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
