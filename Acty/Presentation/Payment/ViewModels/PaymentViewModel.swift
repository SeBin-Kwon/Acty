//
//  PaymentViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 6/18/25.
//

import Foundation
import Combine
import iamport_ios

final class PaymentViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let paymentService: PaymentServiceProtocol
    private let orderService: OrderServiceProtocol
    
    struct Input {
        // 주문 정보
        var activityId: String = ""
        var reservationItemName: String = ""
        var reservationItemTime: String = ""
        var participantCount: Int = 1
        var totalPrice: Int = 0
        
        // 구매자 정보
        var buyerName: String = ""
        
        // 액션
        let paymentButtonTapped = PassthroughSubject<Void, Never>()
        let paymentCompleted = PassthroughSubject<IamportResponse, Never>()
    }
    
    struct Output {
        var isLoading = false
        var paymentSuccess = PassthroughSubject<PortonePaymentResponseDTO, Never>()
        var paymentFailed = PassthroughSubject<String, Never>()
        var showPaymentView = PassthroughSubject<PortonePaymentRequestDTO, Never>()
    }
    
    init(paymentService: PaymentServiceProtocol, orderService: OrderServiceProtocol) {
        self.paymentService = paymentService
        self.orderService = orderService
        transform()
    }
    
    func transform() {
        // 결제 버튼 탭 처리
        input.paymentButtonTapped
            .sink { [weak self] in
                self?.initiatePayment()
            }
            .store(in: &cancellables)
        
        // 결제 완료 처리
        input.paymentCompleted
            .sink { [weak self] response in
                self?.handlePaymentResult(response)
            }
            .store(in: &cancellables)
    }
    
    private func initiatePayment() {
        guard validateInput() else {
            output.paymentFailed.send("입력 정보를 확인해주세요.")
            return
        }
        
        setLoading(true)
        
        // 1. 서버에 주문 생성 요청
        Task {
            do {
                let createOrderRequest = OrdersRequestDTO(
                    id: input.activityId,
                    reservationItemName: input.reservationItemName,
                    reservationItemTime: input.reservationItemTime,
                    participantCount: input.participantCount,
                    totalPrice: input.totalPrice
                )
                
                let orderResponse = try await orderService.createOrder(request: createOrderRequest)
                
                // 2. 포트원 결제 요청 데이터 생성
                let portoneRequest = PortonePaymentRequestDTO(
                    orderCode: orderResponse.orderCode,
                    merchantUid: orderResponse.orderCode, // order_code를 merchant_uid로 사용
                    amount: orderResponse.totalPrice, // String으로 받음
                    orderName: input.reservationItemName,
                    buyerName: input.buyerName,
                    payMethod: "card",
                    pgProvider: "html5_inicis"
                )
                
                await MainActor.run {
                    self.setLoading(false)
                    self.output.showPaymentView.send(portoneRequest)
                }
                
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.output.paymentFailed.send("주문 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handlePaymentResult(_ response: IamportResponse) {
        setLoading(true)
        
        let paymentResult = paymentService.processPaymentResult(response)
        
        if paymentResult.success {
            setLoading(false)
            output.paymentSuccess.send(paymentResult)
        } else {
            setLoading(false)
            let errorMessage = paymentResult.errorMsg ?? "결제에 실패했습니다."
            output.paymentFailed.send(errorMessage)
        }
    }
    
    private func setLoading(_ isLoading: Bool) {
        output.isLoading = isLoading
    }
    
    private func validateInput() -> Bool {
        guard !input.activityId.isEmpty,
              !input.reservationItemName.isEmpty,
              !input.reservationItemTime.isEmpty,
              !input.buyerName.isEmpty,
              input.participantCount > 0,
              input.totalPrice > 0 else {
            return false
        }
        
        return true
    }
}
