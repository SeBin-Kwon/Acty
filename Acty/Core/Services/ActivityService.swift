//
//  ActivityService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

protocol ActivityServiceProtocol {
    func fetchActivities(dto: ActivityRequestDTO) async -> [Activity]
    func fetchNewActivities(dto: ActivityRequestDTO) async -> [Activity]
}

final class ActivityService: ActivityServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchActivities(dto: ActivityRequestDTO) async -> [Activity] {
        do {
            let result: ActivityListResponseDTO = try await networkManager.fetchResults(api: ActivityEndPoint.activity(dto))
            print("액티비티 fetch 성공")
            return result.toEntity().activities
        } catch {
            print("액티비티 fetch 실패")
            print(error)
            return []
        }
    }
    
    func fetchNewActivities(dto: ActivityRequestDTO) async -> [Activity] {
        do {
            let result: ActivityListResponseDTO = try await networkManager.fetchResults(api: ActivityEndPoint.newActivity(dto))
            print("액티비티 fetch 성공")
            print(result.data)
            return result.toEntity().activities
        } catch {
            print("액티비티 fetch 실패")
            print(error)
            return []
        }
    }
}

class MockActivityService: ActivityServiceProtocol {
    
    func fetchNewActivities(dto: ActivityRequestDTO) async -> [Activity] {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            Activity(
                id: "mock1",
                title: "한강 피크닉 패키지",
                country: "대한민국",
                category: "관광",
                thumbnails: ["/data/activities/6842398-sd_640_360_30fps_1747149175575.mp4", "/data/activities/niklas-ohlrogge-niamoh-de-tc2Cts4aXCw_1747149046143.jpg"],
                geolocation: Geolocation(longitude: 126.9356, latitude: 37.5219),
                price: Price(original: 50000, final: 35000),
                tags: ["인기", "할인"],
                pointReward: 350,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 245
            ),
            Activity(
                id: "mock2",
                title: "N서울타워 스카이 라운지",
                country: "대한민국",
                category: "관광",
                thumbnails: ["/data/activities/nseoultower_1.jpg"],
                geolocation: Geolocation(longitude: 126.9883, latitude: 37.5512),
                price: Price(original: 25000, final: 25000),
                tags: ["베스트"],
                pointReward: 250,
                isAdvertisement: true,
                isKeep: true,
                keepCount: 892
            ),
            Activity(
                id: "mock3",
                title: "경복궁 야간 특별 관람",
                country: "대한민국",
                category: "문화",
                thumbnails: ["/data/activities/gyeongbok_night_1.jpg"],
                geolocation: Geolocation(longitude: 126.9770, latitude: 37.5796),
                price: Price(original: 15000, final: 12000),
                tags: ["한정", "야간"],
                pointReward: 120,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 156
            ),
            Activity(
                id: "mock4",
                title: "홍대 거리 푸드 투어",
                country: "대한민국",
                category: "음식",
                thumbnails: ["/data/activities/hongdae_food_1.jpg"],
                geolocation: Geolocation(longitude: 126.9250, latitude: 37.5563),
                price: Price(original: 45000, final: 39000),
                tags: ["맛집", "신상"],
                pointReward: 390,
                isAdvertisement: false,
                isKeep: true,
                keepCount: 67
            ),
            Activity(
                id: "mock5",
                title: "강남 스카이 바 체험",
                country: "대한민국",
                category: "엔터테인먼트",
                thumbnails: ["/data/activities/gangnam_skybar_1.jpg"],
                geolocation: Geolocation(longitude: 127.0276, latitude: 37.4979),
                price: Price(original: 80000, final: 64000),
                tags: ["프리미엄", "20% 할인"],
                pointReward: 640,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 432
            ),
            Activity(
                id: "mock6",
                title: "부산 해운대 서핑 레슨",
                country: "대한민국",
                category: "스포츠",
                thumbnails: ["/data/activities/busan_surfing_1.jpg"],
                geolocation: Geolocation(longitude: 129.1603, latitude: 35.1584),
                price: Price(original: 60000, final: 48000),
                tags: ["체험", "초보환영"],
                pointReward: 480,
                isAdvertisement: false,
                isKeep: false,
                keepCount: 78
            )
        ]
    }
    
   func fetchActivities(dto: ActivityRequestDTO) async -> [Activity] {
       try? await Task.sleep(nanoseconds: 500_000_000)
       
       return [
           Activity(
               id: "mock1",
               title: "한강 피크닉 패키지",
               country: "대한민국",
               category: "관광",
               thumbnails: ["/data/activities/6842398-sd_640_360_30fps_1747149175575.mp4", "/data/activities/niklas-ohlrogge-niamoh-de-tc2Cts4aXCw_1747149046143.jpg"],
               geolocation: Geolocation(longitude: 126.9356, latitude: 37.5219),
               price: Price(original: 50000, final: 35000),
               tags: ["인기", "할인"],
               pointReward: 350,
               isAdvertisement: false,
               isKeep: false,
               keepCount: 245
           ),
           Activity(
               id: "mock2",
               title: "N서울타워 스카이 라운지",
               country: "대한민국",
               category: "관광",
               thumbnails: ["/data/activities/nseoultower_1.jpg"],
               geolocation: Geolocation(longitude: 126.9883, latitude: 37.5512),
               price: Price(original: 25000, final: 25000),
               tags: ["베스트"],
               pointReward: 250,
               isAdvertisement: true,
               isKeep: true,
               keepCount: 892
           ),
           Activity(
               id: "mock3",
               title: "경복궁 야간 특별 관람",
               country: "대한민국",
               category: "문화",
               thumbnails: ["/data/activities/gyeongbok_night_1.jpg"],
               geolocation: Geolocation(longitude: 126.9770, latitude: 37.5796),
               price: Price(original: 15000, final: 12000),
               tags: ["한정", "야간"],
               pointReward: 120,
               isAdvertisement: false,
               isKeep: false,
               keepCount: 156
           ),
           Activity(
               id: "mock4",
               title: "홍대 거리 푸드 투어",
               country: "대한민국",
               category: "음식",
               thumbnails: ["/data/activities/hongdae_food_1.jpg"],
               geolocation: Geolocation(longitude: 126.9250, latitude: 37.5563),
               price: Price(original: 45000, final: 39000),
               tags: ["맛집", "신상"],
               pointReward: 390,
               isAdvertisement: false,
               isKeep: true,
               keepCount: 67
           ),
           Activity(
               id: "mock5",
               title: "강남 스카이 바 체험",
               country: "대한민국",
               category: "엔터테인먼트",
               thumbnails: ["/data/activities/gangnam_skybar_1.jpg"],
               geolocation: Geolocation(longitude: 127.0276, latitude: 37.4979),
               price: Price(original: 80000, final: 64000),
               tags: ["프리미엄", "20% 할인"],
               pointReward: 640,
               isAdvertisement: false,
               isKeep: false,
               keepCount: 432
           ),
           Activity(
               id: "mock6",
               title: "부산 해운대 서핑 레슨",
               country: "대한민국",
               category: "스포츠",
               thumbnails: ["/data/activities/busan_surfing_1.jpg"],
               geolocation: Geolocation(longitude: 129.1603, latitude: 35.1584),
               price: Price(original: 60000, final: 48000),
               tags: ["체험", "초보환영"],
               pointReward: 480,
               isAdvertisement: false,
               isKeep: false,
               keepCount: 78
           )
       ]
   }
}
