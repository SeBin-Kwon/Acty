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
        var filterButtonTapped = PassthroughSubject<(Country?, ActivityCategory?), Never>()
//        var activityDetail = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        var newActivityList = [Activity]()
        var activityList = [Activity]()
//        var activityDescription = ""
//        var activityDetails = [String: ActivityDetail]()
    }
    
    init(activityService: ActivityServiceProtocol) {
        self.activityService = activityService
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: "", category: "", limit: 5, next: "")
                Task {
                    let activityResult = await self.activityService.fetchActivities(dto: dto)
                    let newActivityResult = await self.activityService.fetchNewActivities(dto: dto)
                    await MainActor.run {
//                        print("😀 newActivityList: \(newActivityResult)")
//                        print("🤣 activityList: \(activityResult)")
                        self.output.newActivityList = newActivityResult
                        self.output.activityList = activityResult
                    }
                }
            }
            .store(in: &cancellables)
        
        input.filterButtonTapped
            .sink { [weak self] (country, category) in
                guard let self else { return }
                
                let dto = ActivityRequestDTO(country: country?.koreaName ?? "", category: category?.koreaName ?? "", limit: 5, next: "")
                
                Task {
                    let activityResult = await self.activityService.fetchActivities(dto: dto)
                    await MainActor.run {
//                        print("🤣 activityList: \(activityResult)")
                        self.output.activityList = activityResult
                    }
                }
            }
            .store(in: &cancellables)
        
//        input.activityDetail
//            .sink { [weak self] id in
//                guard let self else { return }
//                print("detail: \(id)")
//                Task {
//                    let activityResult = await self.activityService.fetchActivityDetails(id: id)
//                    await MainActor.run {
//                        self.output.activityDetails[id] = activityResult
//                        self.output.activityDescription = activityResult.description
//                    }
//                }
//            }
//            .store(in: &cancellables)
    }
}
