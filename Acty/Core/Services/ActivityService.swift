//
//  ActivityService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

protocol ActivityServiceProtocol {
    func fetchActivities(dto: ActivityRequestDTO) async -> [Activity]
}

final class ActivityService: ActivityServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchActivities(dto: ActivityRequestDTO) async -> [Activity] {
        do {
            let result: ActivityResponseDTO = try await networkManager.fetchResults(api: ActivityEndPoint.activity(dto))
            print("액티비티 fetch 성공")
            print(result)
        } catch {
            print("액티비티 fetch 실패")
            print(error)
        }
        return []
    }
}
