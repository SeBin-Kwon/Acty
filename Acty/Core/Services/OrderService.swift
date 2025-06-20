//
//  OrderService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/19/25.
//

import Foundation

protocol OrderServiceProtocol {
    func createOrder(request: OrdersRequestDTO) async throws -> OrdersResponseDTO
    func getOrderHistory() async throws -> [OrdersResponseDTO]
}

final class OrderService: OrderServiceProtocol {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    // 주문 생성 (서버에서 order_code 받아오기)
    func createOrder(request: OrdersRequestDTO) async throws -> OrdersResponseDTO {
        print("주문 생성 요청: \(request)")
        
        let response: OrdersResponseDTO = try await networkManager.fetchResults(
            api: OrdersEndPoint.orders(request) as any EndPoint
        )
        
        print("주문 생성 완료 - order_code: \(response.orderCode)")
        return response
    }
    
    // 주문 내역 조회
    func getOrderHistory() async throws -> [OrdersResponseDTO] {
        print("주문 내역 조회 요청")
        
        let response: OrdersHistoryResponseDTO = try await networkManager.fetchResults(
            api: OrdersEndPoint.ordersHistory as any EndPoint
        )
        
        print("주문 내역 조회 완료 - 총 \(response.orders.count)개")
        return response.orders
    }
}

// MARK: - 주문 내역 조회용 응답 DTO
struct OrdersHistoryResponseDTO: Decodable {
    let orders: [OrdersResponseDTO]
}
