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
    private let bannerService: BannerServiceProtocol
    
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
        var isLoading = false
//        var activityDescription = ""
//        var activityDetails = [String: ActivityDetail]()
        var banners = [Banner]()
        var bannersLoaded = PassthroughSubject<Void, Never>()
    }
    
    init(activityService: ActivityServiceProtocol, bannerService: BannerServiceProtocol) {
        self.activityService = activityService
        self.bannerService = bannerService
        transform()
    }
    
    func transform() {
        input.onAppear
            .sink { [weak self] _ in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: "", category: "", limit: 10, next: "")
                fetchActivityData(isOnAppear: true, dto: dto)
                self.loadBanners()
            }
            .store(in: &cancellables)
        
        input.filterButtonTapped
            .sink { [weak self] (country, category) in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: country?.koreaName ?? "", category: category?.koreaName ?? "", limit: 10, next: "")
                nextCursor = ""
                output.activityList = []
                fetchActivityData(isOnAppear: false, dto: dto)
                currentFilters = (country?.koreaName ?? "", category?.koreaName ?? "")
            }
            .store(in: &cancellables)
        
        input.loadData
            .sink { [weak self] in
                guard let self else { return }
                let dto = ActivityRequestDTO(country: currentFilters.country, category: currentFilters.category, limit: 10, next: nextCursor)
                pagenationData(dto: dto)
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
    
    private func loadBanners() {
            Task {
                let banners = try await bannerService.fetchMainBanners()
                
                await MainActor.run {
                    self.output.banners = banners
                    if !banners.isEmpty {
                        self.output.bannersLoaded.send(())
                    }
                }
            }
        }
    
    private func fetchActivityData(isOnAppear: Bool, dto: ActivityRequestDTO) {
        guard !output.isLoading else { return }
        
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            if isOnAppear {
                let newActivityResult = await self.activityService.fetchNewActivities(dto: dto)
                await MainActor.run {
                    output.newActivityList = newActivityResult
                }
            }
            let activityResult = await self.activityService.fetchActivities(dto: dto)
            await MainActor.run {
                
                nextCursor = activityResult.nextCursor ?? ""
                output.activityList.append(contentsOf: activityResult.activities)
                print(activityResult)
                output.isLoading = false
            }
            
        }
        
    }
    
    private func pagenationData(dto: ActivityRequestDTO) {
        if dto.next.isEmpty {
            print("마지막 페이지")
        } else {
            fetchActivityData(isOnAppear: false, dto: dto)
        }
    }
}
