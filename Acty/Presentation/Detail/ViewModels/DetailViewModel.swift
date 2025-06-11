//
//  DetailViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import Foundation
import Combine

final class DetailViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    private let activityService: ActivityServiceProtocol
    
    struct Input {
        var onAppear = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        var activityDetails = [String: ActivityDetail]()
    }
    
    init(activityService: ActivityServiceProtocol) {
        self.activityService = activityService
        transform()
    }
    
    func transform() {
        
        input.onAppear
            .sink { [weak self] id in
                guard let self else { return }
                print("detail: \(id)")
                Task {
                    let activityResult = await self.activityService.fetchActivityDetails(id: id)
                    await MainActor.run {
                        self.output.activityDetails[id] = activityResult
                    }
                }
            }
            .store(in: &cancellables)
    }
}
