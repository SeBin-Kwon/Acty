//
//  NetworkManager.swift
//  Acty
//
//  Created by Sebin Kwon on 5/12/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchResults<T: Decodable>(api: EndPoint) async throws -> T {
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
                }
            }
        }
    }
}
