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
    
    private var currentFilters: (country: String, category: String) = ("", "")
    private var nextCursor = ""
    
    struct Input {
        var onAppear = PassthroughSubject<Void, Never>()
        var filterButtonTapped = PassthroughSubject<(Country?, ActivityCategory?), Never>()
        var loadData = PassthroughSubject<Void, Never>()
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
                let dto = ActivityRequestDTO(country: "", category: "", limit: 10, next: "")
                fetchActivityData(isOnAppear: true, dto: dto)
                
            }
            .store(in: &cancellables)
        
        input.filterButtonTapped
            .sink { [weak self] (country, category) in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: country?.koreaName ?? "", category: category?.koreaName ?? "", limit: 10, next: "")
                fetchActivityData(isOnAppear: false, dto: dto)
                currentFilters = (country?.koreaName ?? "", category?.koreaName ?? "")
            }
            .store(in: &cancellables)
        
        input.loadData
            .sink { [weak self] in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: currentFilters.country, category: currentFilters.category, limit: 10, next: nextCursor)
                fetchActivityData(isOnAppear: false, dto: dto)
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
    
    private func fetchActivityData(isOnAppear: Bool, dto: ActivityRequestDTO) {
        if isOnAppear {
            Task {
                let activityResult = await self.activityService.fetchActivities(dto: dto)
                let newActivityResult = await self.activityService.fetchNewActivities(dto: dto)
                await MainActor.run {
                    self.output.newActivityList = newActivityResult
                    self.output.activityList = activityResult.activities
                    nextCursor = activityResult.nextCursor ?? ""
                    print(activityResult)
                }
            }
        } else {
            if dto.next.isEmpty {
                Task {
                    let activityResult = await self.activityService.fetchActivities(dto: dto)
                    await MainActor.run {
                        self.output.activityList = activityResult.activities
                    }
                }
            } else {
                Task {
                    let activityResult = await self.activityService.fetchActivities(dto: dto)
                    await MainActor.run {
                        self.output.activityList.append(contentsOf: activityResult.activities)
                    }
                }
            }
        }
    }
}
