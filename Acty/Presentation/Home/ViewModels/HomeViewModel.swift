//
//  HomeViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation
import Combine

final class HomeViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    private let activityService: ActivityServiceProtocol
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        
    }
    
    init(activityService: ActivityServiceProtocol) {
        self.activityService = activityService
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                let dto = ActivityRequestDTO(country: "대한민국", category: "관광", limit: 5, next: "")
                Task {
                    await self?.activityService.fetchActivities(dto: dto)
                }
            }
            .store(in: &cancellables)
    }
}
