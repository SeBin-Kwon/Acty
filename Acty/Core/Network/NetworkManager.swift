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
           (url.contains("login") || url.contains("join") || url.contains("refresh")) {
            print("🔓 인증 불필요한 API: \(url)")
            completion(.success(request))
            return
        }
        
        do {
            let token = try tokenService.getAccessToken()
            request.headers.add(name: "Authorization", value: token)
            print("🔐 토큰 추가됨: Bearer \(token.prefix(10))...")
            completion(.success(request))
        } catch {
            print("❌ 토큰 없음: \(error)")
            completion(.success(request))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            print("🚫 재시도 불가: \(error)")
            completion(.doNotRetry)
            return
        }
        

        if let url = request.request?.url?.absoluteString, url.contains("refresh") {
            print("🔄 리프레시 API 실패 - 재시도 안함")
            completion(.doNotRetry)
            return
        }
        
        print("🔄 401 에러 - 토큰 갱신 시도")
        Task {
            do {
                let newToken = try await tokenService.refreshToken()
                print("✅ 토큰 갱신 성공: \(newToken.prefix(10))...")
                completion(.retry)
            } catch {
                print("❌ 토큰 갱신 실패 - 로그아웃: \(error)")
                try? tokenService.deleteTokens()
                completion(.doNotRetry)
            }
        }
    }
}

final class NetworkManager: Sendable {
    private let session: Session
    
    init() {
        self.session = Session()
    }
    
    init(tokenService: TokenServiceProtocol) {
        let interceptor = AuthInterceptor(tokenService: tokenService)
        self.session = Session(interceptor: interceptor)
    }
    
    func fetchResults<T: Decodable>(api: EndPoint) async throws -> T {
        print("📤 API 요청: \(api.method.rawValue) \(api.endPoint)")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                api.endPoint,
                method: api.method,
                parameters: api.parameters,
                encoding: api.encoding,
                headers: api.headers
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let result):
                    print("✅ API 성공: \(api.endPoint)")
                    continuation.resume(returning: result)
                case .failure(let error):
                    print("❌ API 실패: \(api.endPoint) - \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
