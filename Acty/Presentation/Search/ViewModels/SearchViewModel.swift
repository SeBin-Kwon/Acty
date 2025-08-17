//
//  SearchViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 7/13/25.
//

import Foundation
import Combine

final class SearchViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let activityService: ActivityServiceProtocol
    private let userDefaultsManager = UserDefaultsManager.shared
    private var lastSearchQuery = ""
    private var searchHistory = [String]()
    
    struct Input {
        var searchTriggered = PassthroughSubject<String, Never>()
        var searchTextChanged = PassthroughSubject<String, Never>()
        var clearSearch = PassthroughSubject<Void, Never>()
        var recentSearchSelected = PassthroughSubject<String, Never>()
        var removeRecentSearch = PassthroughSubject<String, Never>()
        var clearRecentSearches = PassthroughSubject<Void, Never>()
        var loadMoreResults = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var searchResults = [Activity]()
        var recentSearches = [String]()
        var isLoading = CurrentValueSubject<Bool, Never>(false)
        var hasSearched = false
        var errorMessage = PassthroughSubject<String, Never>()
    }
    
    init(activityService: ActivityServiceProtocol) {
        self.activityService = activityService
        setupInitialData()
        transform()
    }
    
    func transform() {
        // 검색 실행
        input.searchTriggered
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
        
        // 검색 초기화
        input.clearSearch
            .sink { [weak self] in
                self?.clearSearchResults()
            }
            .store(in: &cancellables)
        
        // 최근 검색어 선택
        input.recentSearchSelected
            .sink { [weak self] keyword in
                self?.performSearch(query: keyword)
            }
            .store(in: &cancellables)
        
        // 특정 최근 검색어 삭제
        input.removeRecentSearch
            .sink { [weak self] keyword in
                self?.removeFromSearchHistory(keyword)
            }
            .store(in: &cancellables)
        
        // 최근 검색어 전체 삭제
        input.clearRecentSearches
            .sink { [weak self] in
                self?.clearSearchHistory()
            }
            .store(in: &cancellables)
        
        // 더 많은 결과 로드 (무한 스크롤)
        input.loadMoreResults
            .sink { [weak self] in
                self?.loadMoreSearchResults()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func setupInitialData() {
        // 검색 기록 로드 (UserDefaults에서)
        loadSearchHistory()
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else { return }
        
        lastSearchQuery = query
        output.isLoading.send(true)
        output.hasSearched = true
        
        // 검색 기록에 추가
        addToSearchHistory(query)
        
        Task {
            do {
                let searchResults = try await activityService.fetchSearchActivities(title: query)
                
                await MainActor.run {
                    self.output.searchResults = searchResults
                    self.output.isLoading.send(false)
                    
                    if searchResults.isEmpty {
                        print("검색 결과 없음: \(query)")
                    } else {
                        print("검색 완료: \(searchResults.count)개 결과")
                    }
                }
            } catch let error as AppError {
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.errorMessage.send(error.localizedDescription)
                }
            } catch {
                await MainActor.run {
                    self.output.isLoading.send(false)
                    let appError = (error as? AppError) ?? AppError.networkError("검색 중 오류")
                    self.output.errorMessage.send(appError.localizedDescription)
                }
            }
        }
    }
    
    private func clearSearchResults() {
        output.searchResults = []
        output.hasSearched = false
        output.isLoading.send(false)
    }
    
    private func loadMoreSearchResults() {
        // 무한 스크롤 구현 (현재는 기본 구현체만)
        guard !lastSearchQuery.isEmpty && !output.isLoading.value else { return }
        
        print("더 많은 검색 결과 로드: \(lastSearchQuery)")
        // TODO: 페이지네이션 API 호출
    }
    
    // MARK: - Search History Management
    
    private func loadSearchHistory() {
        if let savedHistory = userDefaultsManager.loadStringArray(forKey: UserDefaultsManager.Keys.searchHistory) {
            searchHistory = savedHistory
            output.recentSearches = savedHistory
        }
    }
    
    private func addToSearchHistory(_ query: String) {
        // 중복 제거
        searchHistory.removeAll { $0 == query }
        
        // 맨 앞에 추가
        searchHistory.insert(query, at: 0)
        
        // 최대 20개까지만 보관
        if searchHistory.count > 20 {
            searchHistory = Array(searchHistory.prefix(20))
        }
        
        // UserDefaults에 저장
        userDefaultsManager.saveStringArray(searchHistory, forKey: UserDefaultsManager.Keys.searchHistory)
        
        // output 업데이트
        output.recentSearches = searchHistory
    }
    
    private func removeFromSearchHistory(_ query: String) {
        searchHistory.removeAll { $0 == query }
        userDefaultsManager.saveStringArray(searchHistory, forKey: UserDefaultsManager.Keys.searchHistory)
        output.recentSearches = searchHistory
    }
    
    func clearSearchHistory() {
        searchHistory.removeAll()
        userDefaultsManager.remove(forKey: UserDefaultsManager.Keys.searchHistory)
        output.recentSearches = []
    }
}

extension MockActivityService {
    func searchActivities(title: String) async -> [Activity] {
        // Mock 데이터에서 검색 시뮬레이션
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8초 딜레이
        
        let allActivities = [
            Activity(
                id: "search1",
                title: "한강 야경 피크닉",
                country: "대한민국",
                category: "관광",
                thumbnails: [],
                geolocation: Geolocation(longitude: 126.9356, latitude: 37.5219),
                price: Price(original: 45000, final: 35000),
                tags: ["야경", "피크닉"],
                pointReward: 350,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 189
            ),
            Activity(
                id: "search2",
                title: "제주도 패러글라이딩",
                country: "대한민국",
                category: "익스트림",
                thumbnails: [],
                geolocation: Geolocation(longitude: 126.5312, latitude: 33.4996),
                price: Price(original: 120000, final: 98000),
                tags: ["익스트림", "제주"],
                pointReward: 980,
                isAdvertisement: false,
                isKeep: true,
                keepCount: 456
            ),
            Activity(
                id: "search3",
                title: "부산 해운대 서핑 체험",
                country: "대한민국",
                category: "스포츠",
                thumbnails: [],
                geolocation: Geolocation(longitude: 129.1603, latitude: 35.1584),
                price: Price(original: 60000, final: 48000),
                tags: ["서핑", "부산"],
                pointReward: 480,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 234
            ),
            Activity(
                id: "search4",
                title: "경복궁 한복 체험",
                country: "대한민국",
                category: "문화",
                thumbnails: [],
                geolocation: Geolocation(longitude: 126.9770, latitude: 37.5796),
                price: Price(original: 25000, final: 20000),
                tags: ["전통", "한복"],
                pointReward: 200,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 312
            ),
            Activity(
                id: "search5",
                title: "홍대 맛집 투어",
                country: "대한민국",
                category: "음식",
                thumbnails: [],
                geolocation: Geolocation(longitude: 126.9250, latitude: 37.5563),
                price: Price(original: 35000, final: 30000),
                tags: ["맛집", "투어"],
                pointReward: 300,
                isAdvertisement: false,
                isKeep: true,
                keepCount: 167
            )
        ]
        
        // 제목에 검색어가 포함된 액티비티만 필터링
        return allActivities.filter { activity in
            activity.title.localizedCaseInsensitiveContains(title) ||
            activity.country.localizedCaseInsensitiveContains(title) ||
            activity.category.localizedCaseInsensitiveContains(title) ||
            activity.tags.contains { $0.localizedCaseInsensitiveContains(title) }
        }
    }
}
