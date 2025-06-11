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
    func fetchActivityDetails(id: String) async -> ActivityDetail
}

final class ActivityService: ActivityServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchActivityDetails(id: String) async -> ActivityDetail {
        do {
            let result: ActivityDetailResponseDTO = try await networkManager.fetchResults(api: ActivityEndPoint.activityDetail(id))
            print("액티비티 Detail fetch 성공")
            return result.toEntity()
        } catch {
            print("액티비티 Detail fetch 실패")
            print(error)
            fatalError()
        }
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
    
    let mockData = ActivityDetail(
            id: "6843f67c5c57725aaa782521",
            title: "세상 패러글라이딩 2기",
            country: "스위스",
            category: "익스트림",
            thumbnails: [
                "/data/activities/paragliding_1.jpeg",
                "/data/activities/paragliding_2.jpeg",
                "/data/activities/paragliding_3.jpeg",
                "/data/activities/paragliding_4.jpeg"
            ],
            geolocation: Geolocation(
                longitude: 127.049914,
                latitude: 37.654215
            ),
            startDate: "2025-07-01",
            endDate: "2025-09-30",
            price: Price(
                original: 605000,
                final: 520000
            ),
            tags: ["New 오픈특가", "인기급상승", "얼리버드"],
            pointReward: 5200,
            restrictions: Restrictions(
                minHeight: 150,
                minAge: 16,
                maxParticipants: 8
            ),
            description: "두려움을 넘고, 하늘을 향한 두 번째 도전이 시작됩니다. 야적은 시들지만, 하늘을 향한 마음은 누구보다 단단한 세상 팀의 비상. 스위스 인터라켄의 아름다운 알프스 산맥을 배경으로 펼쳐지는 패러글라이딩 체험으로 평생 잊지 못할 추억을 만들어보세요.",
            isAdvertisement: false,
            isKeep: true,
            keepCount: 35,
            totalOrderCount: 127,
            schedule: [
                Schedule(
                    duration: "시작 - 10분",
                    description: "안전 교육 및 장비 착용 (우천 시 취소될 수 있습니다)"
                ),
                Schedule(
                    duration: "10분 - 30분",
                    description: "기본 비행 자세 및 착륙 연습"
                ),
                Schedule(
                    duration: "30분 - 1시간 30분",
                    description: "인스트럭터와 함께하는 탠덤 패러글라이딩 체험"
                ),
                Schedule(
                    duration: "1시간 30분 - 2시간",
                    description: "착륙 후 기념사진 촬영 및 소감 나누기"
                )
            ],
            reservationList: [
                ReservationDate(
                    date: "2025-07-01",
                    times: [
                        ReservationTime(time: "09:00", isReserved: false),
                        ReservationTime(time: "11:00", isReserved: true),
                        ReservationTime(time: "13:00", isReserved: false),
                        ReservationTime(time: "15:00", isReserved: false),
                        ReservationTime(time: "17:00", isReserved: true)
                    ]
                ),
                ReservationDate(
                    date: "2025-07-02",
                    times: [
                        ReservationTime(time: "09:00", isReserved: false),
                        ReservationTime(time: "11:00", isReserved: false),
                        ReservationTime(time: "13:00", isReserved: true),
                        ReservationTime(time: "15:00", isReserved: false),
                        ReservationTime(time: "17:00", isReserved: false)
                    ]
                ),
                ReservationDate(
                    date: "2025-07-03",
                    times: [
                        ReservationTime(time: "09:00", isReserved: true),
                        ReservationTime(time: "11:00", isReserved: true),
                        ReservationTime(time: "13:00", isReserved: true),
                        ReservationTime(time: "15:00", isReserved: true),
                        ReservationTime(time: "17:00", isReserved: true)
                    ]
                )
            ],
            creator: Creator(
                userId: "6826cd67e5c54c8fdd914662",
                nickname: "스카이마스터",
                profileImage: "/data/profiles/creator_profile.jpeg",
                introduction: "10년 경력의 패러글라이딩 전문가입니다. 안전하고 즐거운 하늘 여행을 약속드려요! ✈️"
            ),
            createdAt: "2025-06-07T08:21:16.119Z",
            updatedAt: "2025-06-07T08:21:16.119Z"
        )
        
        // 추가 목업 데이터들
        let mockDataList: [ActivityDetail] = [
            ActivityDetail(
                id: "6843f67c5c57725aaa782522",
                title: "아르헨티나에서 서울 맛보기",
                country: "아르헨티나",
                category: "투어",
                thumbnails: [
                    "/data/activities/argentina_1.jpeg",
                    "/data/activities/argentina_2.jpeg"
                ],
                geolocation: Geolocation(
                    longitude: -58.3816,
                    latitude: -34.6037
                ),
                startDate: "2025-07-01",
                endDate: "2025-09-30",
                price: Price(
                    original: 150000,
                    final: 120000
                ),
                tags: ["New 오픈특가"],
                pointReward: 1200,
                restrictions: Restrictions(
                    minHeight: 140,
                    minAge: 12,
                    maxParticipants: 15
                ),
                description: "부에노스아이레스에서 한국 음식을 맛보며 고향의 정취를 느껴보세요.",
                isAdvertisement: false,
                isKeep: false,
                keepCount: 12,
                totalOrderCount: 45,
                schedule: [
                    Schedule(
                        duration: "시작 - 30분",
                        description: "한국 음식점 투어 시작"
                    ),
                    Schedule(
                        duration: "30분 - 2시간",
                        description: "음식 체험 및 문화 교류"
                    )
                ],
                reservationList: [
                    ReservationDate(
                        date: "2025-07-01",
                        times: [
                            ReservationTime(time: "12:00", isReserved: false),
                            ReservationTime(time: "18:00", isReserved: false)
                        ]
                    )
                ],
                creator: Creator(
                    userId: "6826cd67e5c54c8fdd914663",
                    nickname: "아르헨맛집",
                    profileImage: "/data/profiles/argentina_creator.jpeg",
                    introduction: "아르헨티나 거주 5년차, 현지 맛집 전문가입니다 🇦🇷"
                ),
                createdAt: "2025-06-07T08:21:16.119Z",
                updatedAt: "2025-06-07T08:21:16.119Z"
            ),
            
            ActivityDetail(
                id: "6843f67c5c57725aaa782523",
                title: "제주도 해녀 체험",
                country: "한국",
                category: "문화체험",
                thumbnails: [
                    "/data/activities/jeju_1.jpeg",
                    "/data/activities/jeju_2.jpeg",
                    "/data/activities/jeju_3.jpeg"
                ],
                geolocation: Geolocation(
                    longitude: 126.5312,
                    latitude: 33.4996
                ),
                startDate: "2025-06-15",
                endDate: "2025-12-31",
                price: Price(
                    original: 80000,
                    final: 80000
                ),
                tags: ["전통문화", "체험"],
                pointReward: 800,
                restrictions: Restrictions(
                    minHeight: 150,
                    minAge: 18,
                    maxParticipants: 6
                ),
                description: "제주도의 전통 해녀 문화를 직접 체험해보세요. 바다 속 보물을 찾는 특별한 경험이 기다립니다.",
                isAdvertisement: true,
                isKeep: false,
                keepCount: 89,
                totalOrderCount: 234,
                schedule: [
                    Schedule(
                        duration: "시작 - 30분",
                        description: "해녀 복장 착용 및 안전 교육"
                    ),
                    Schedule(
                        duration: "30분 - 2시간",
                        description: "해녀와 함께하는 바다 체험"
                    ),
                    Schedule(
                        duration: "2시간 - 3시간",
                        description: "해산물 시식 및 이야기 나누기"
                    )
                ],
                reservationList: [
                    ReservationDate(
                        date: "2025-07-15",
                        times: [
                            ReservationTime(time: "08:00", isReserved: false),
                            ReservationTime(time: "13:00", isReserved: true)
                        ]
                    )
                ],
                creator: Creator(
                    userId: "6826cd67e5c54c8fdd914664",
                    nickname: "해녀할머니",
                    profileImage: "/data/profiles/haenyeo_creator.jpeg",
                    introduction: "50년 경력의 제주 해녀입니다. 바다의 지혜를 전해드려요 🌊"
                ),
                createdAt: "2025-06-07T08:21:16.119Z",
                updatedAt: "2025-06-07T08:21:16.119Z"
            )
        ]
    
    func fetchActivityDetails(id: String) async -> ActivityDetail {
        return mockData
    }
    
    
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
