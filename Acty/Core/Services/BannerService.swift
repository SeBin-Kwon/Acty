//
//  BannerService.swift
//  Acty
//
//  Created by Sebin Kwon on 7/20/25.
//

import Foundation

protocol BannerServiceProtocol {
    func fetchMainBanners() async throws -> [Banner]
}

final class BannerService: BannerServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchMainBanners() async throws -> [Banner] {
        do {
            let response: BannerListResponseDTO = try await networkManager.fetchResults(
                api: BannerEndPoint.getMainBanners
            )
            
            let banners = response.data.map { $0.toEntity() }
            print("배너 조회 성공: \(banners.count)개")
            return banners
            
        } catch {
            print("배너 조회 실패: \(error)")
            throw error
        }
    }
}

class MockBannerService: BannerServiceProtocol {
    func fetchMainBanners() async throws -> [Banner] {
        // 테스트용 더미 데이터
        return [
            Banner(
                name: "테스트 배너 1",
                imageUrl: "/images/banner1.jpg",
                payload: Payload(type: .webview, value: "https://example.com")
            ),
            Banner(
                name: "테스트 배너 2",
                imageUrl: "/images/banner2.jpg",
                payload: Payload(type: .webview, value: "https://example.com")
            ),
            Banner(
                name: "테스트 배너 3",
                imageUrl: "/images/banner3.jpg",
                payload: Payload(type: .webview, value: "https://example.com")
            )
        ]
    }
}
