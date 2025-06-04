//
//  ActivityService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

protocol ActivityServiceProtocol {
    func fetchActivities() -> [Activity]
}

final class ActivityService: ActivityServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchActivities() -> [Activity] {
//        let result: ActivityResponseDTO = try await networkManager.fetchResults(api: .activity)
        return []
    }
}
