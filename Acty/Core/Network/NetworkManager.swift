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
        
        print("🔍 AuthInterceptor.adapt() 호출됨")
        print("🌐 요청 URL: \(request.url?.absoluteString ?? "nil")")
        
        if let requiresAuth = request.value(forHTTPHeaderField: "X-Requires-Auth") {
            print("🏷 X-Requires-Auth 헤더 값: \(requiresAuth)")
            request.setValue(nil, forHTTPHeaderField: "X-Requires-Auth")
            if requiresAuth == "false" {
                print("🔓 인증 불필요한 API: \(request.url?.absoluteString ?? "")")
                completion(.success(request))
                return
            }
        }
        print("🔐 토큰 추가 시도 중...")
        do {
            let token = try tokenService.getAccessToken()
            request.headers.add(name: "Authorization", value: token)
            print("🔐 엑세스 토큰: \(token)")
            completion(.success(request))
        } catch {
            print("❌ 토큰 없음: \(error)")
            completion(.failure(AppError.authenticationRequired))
        }
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 || response.statusCode == 419 else {
            print("🚫 재시도 불가: \(error)")
            completion(.doNotRetry)
            return
        }
        

        if let url = request.request?.url?.absoluteString, url.contains("refresh") {
            print("🔄 리프레시 API 실패 - 재시도 안함")
            completion(.doNotRetry)
            return
        }
        
        print("🔄 \(response.statusCode) 에러 - 토큰 갱신 시도")
        Task {
            do {
                let newToken = try await tokenService.refreshToken()
                print("✅ 토큰 갱신 성공: \(newToken.prefix(10))...")
                completion(.retry)
            } catch {
                print("❌ 토큰 갱신 실패 - 네트워크매니저: \(error)")
//                try? tokenService.deleteTokens()
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
        print("📤 API 요청: \(api.method.rawValue) \(api.path)")
        var headers = api.headers
                
        if !api.isAuthRequired {
            headers.add(name: "X-Requires-Auth", value: "false")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                api.path,
                method: api.method,
                parameters: api.parameters,
                encoding: api.encoding,
                headers: headers
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let result):
                    print("✅ API 성공: \(api.path)")
                    continuation.resume(returning: result)
                case .failure(let error):
                    print("❌ API 실패: \(api.path) - \(error)")
                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                        print("📋 서버 응답: \(errorString)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension NetworkManager {
    
    // MARK: - MultipartFormData 파일 업로드
    func uploadFiles<T: Decodable>(api: EndPoint, images: [Data], fileNames: [String]? = nil) async throws -> T {
        print("📤 파일 업로드 API 요청: \(api.method.rawValue) \(api.path)")
        
        var headers = api.headers
        
        if !api.isAuthRequired {
            headers.add(name: "X-Requires-Auth", value: "false")
        }
        
        // Content-Type을 multipart/form-data로 변경 (Alamofire가 자동으로 boundary 추가)
        headers.remove(name: "Content-Type")
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: { multipartFormData in
                    // 각 이미지를 files 필드로 추가
                    for (index, imageData) in images.enumerated() {
                        let fileName = fileNames?[safe: index] ?? "image_\(index).jpg"
                        multipartFormData.append(
                            imageData,
                            withName: "files",
                            fileName: fileName,
                            mimeType: "image/jpeg"
                        )
                    }
                },
                to: api.path,
                method: api.method,
                headers: headers
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let result):
                    print("✅ 파일 업로드 성공: \(api.path)")
                    continuation.resume(returning: result)
                case .failure(let error):
                    print("❌ 파일 업로드 실패: \(api.path) - \(error)")
                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                        print("📋 서버 응답: \(errorString)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// 안전한 배열 접근을 위한 extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
