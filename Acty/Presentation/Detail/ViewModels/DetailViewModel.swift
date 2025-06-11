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
        var activityDetail: ActivityDetail? = nil
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
                    let result = await self.activityService.fetchActivityDetails(id: id)
//                    print("🤣 Detail: \(result)")
                    await MainActor.run {
                        self.output.activityDetail = result
                    }
                }
            }
            .store(in: &cancellables)
    }
}
