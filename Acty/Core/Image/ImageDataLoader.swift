//
//  ImageDataLoader.swift
//  Acty
//
//  Created by Sebin Kwon on 6/10/25.
//

import Foundation
import Nuke

final class ImageDataLoader: DataLoading {
    private let tokenService: TokenServiceProtocol
    private let baseLoader: DataLoader
    
    init(tokenService: TokenServiceProtocol) {
        self.tokenService = tokenService
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = ["SeSACKey": API_KEY]
        self.baseLoader = DataLoader(configuration: sessionConfig)
    }
    
    func loadData(
        with request: URLRequest,
        didReceiveData: @escaping (Data, URLResponse) -> Void,
        completion: @escaping (Error?) -> Void
    ) -> Cancellable {
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            DispatchQueue.main.async {
                completion(URLError(.notConnectedToInternet))
            }
            return EmptyCancellable()
        }
        
        guard let url = request.url,
              !url.absoluteString.isEmpty,
              url.absoluteString != BASE_URL else {
            DispatchQueue.main.async {
                completion(URLError(.badURL))
            }
            return EmptyCancellable()
        }
        
        var authenticatedRequest = request
        
        do {
            let token = try tokenService.getAccessToken()
            authenticatedRequest.setValue(token, forHTTPHeaderField: "Authorization")
        } catch {
            print("ImageDataLoader - Error fetching token:", error)
        }
        
        return baseLoader.loadData(
            with: authenticatedRequest,
            didReceiveData: didReceiveData,
            completion: completion
        )
    }
}

final class EmptyCancellable: Cancellable {
    func cancel() {}
}
