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
        var activityId: String = ""
        var selectedDate: String = ""
        var selectedTime: (String, String) = ("", "")
        var participantCount = 1
        var totalPrice = 0
        var productName = ""
        var buyerName: String = "권세빈"
        
        let paymentButtonTapped = PassthroughSubject<Void, Never>()
        let paymentCompleted = PassthroughSubject<IamportResponse?, Never>()
    }
    
    struct Output {
        var isLoading = false
        var paymentSuccess = PassthroughSubject<PortonePaymentResponseDTO, Never>()
        var paymentFailed = PassthroughSubject<String, Never>()
        var showingPaymentSheet = false
        var payment: IamportPayment? = nil
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
        
        // 서버에 주문 생성 요청
        Task {
            do {
                let createOrderRequest = OrdersRequestDTO(
                    id: input.activityId,
                    reservationItemName: input.selectedDate,
                    reservationItemTime: input.selectedTime.1,
                    participantCount: input.participantCount,
                    totalPrice: input.totalPrice
                )
                
                let orderResponse = try await orderService.createOrder(request: createOrderRequest)
                print("서버 주문 생성 성공")
                // 포트원 결제 요청 데이터 생성
                let portoneRequest = PortonePaymentRequestDTO(
                    orderCode: orderResponse.orderCode,
                    merchantUid: orderResponse.orderCode, // order_code를 merchant_uid로 사용
                    amount: String(orderResponse.totalPrice),
                    orderName: input.selectedDate,
                    buyerName: input.buyerName,
                    payMethod: "card",
                    pgProvider: "html5_inicis"
                )
                
                let payment = IamportPayment(
                    pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                    merchant_uid: portoneRequest.merchantUid,
                    amount: portoneRequest.amount).then {
                        $0.pay_method = PayMethod.card.rawValue
                        $0.name = input.productName
                        $0.buyer_name = input.buyerName
                        $0.app_scheme = "acty-payment"
                    }
                
                print("포트원 결제 요청 데이터 생성 성공")
                
                await MainActor.run {
                    self.setLoading(false)
                    self.output.showingPaymentSheet = true
                    self.output.payment = payment
                }
                
            } catch {
                await MainActor.run {
                    self.setLoading(false)
                    self.output.paymentFailed.send("주문 생성 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func handlePaymentResult(_ response: IamportResponse?) {
        output.showingPaymentSheet = false
        
        setLoading(true)
        
        guard let response = response else {
            setLoading(false)
            output.paymentFailed.send("결제가 취소되었습니다.")
            return
        }
        
        do {
            let paymentResult = try paymentService.processPaymentResult(response)
            
            if paymentResult.success {
                setLoading(false)
                output.paymentSuccess.send(paymentResult)
                Task {
                    await validatePayment(impUid: paymentResult.impUid, merchantUid: paymentResult.merchantUid)
                }
                
            } else {
                setLoading(false)
                let errorMessage = paymentResult.errorMsg ?? "결제에 실패했습니다."
                output.paymentFailed.send(errorMessage)
            }
        } catch {
            setLoading(false)
            output.paymentFailed.send("결제 처리 중 오류: \(error.localizedDescription)")
        }
    }
    
    private func validatePayment(impUid: String?, merchantUid: String?) async {
        guard let impUid, let merchantUid else {
            await MainActor.run {
                self.setLoading(false)
                self.output.paymentFailed.send("결제 정보가 올바르지 않습니다.")
            }
            return
        }
        do {
            let validationResult = try await paymentService.validatePayment(
                impUid: impUid,
                orderCode: merchantUid
            )
            
            await MainActor.run {
                self.setLoading(false)
                print("결제 검증 성공")
            }
        } catch {
            await MainActor.run {
                self.setLoading(false)
                self.output.paymentFailed.send("결제 검증 중 오류: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func setLoading(_ isLoading: Bool) {
        output.isLoading = isLoading
    }
    
    private func validateInput() -> Bool {
        guard !input.activityId.isEmpty,
              !input.selectedDate.isEmpty,
              !input.selectedTime.1.isEmpty,
              !input.buyerName.isEmpty,
              input.participantCount > 0,
              input.totalPrice > 0 else {
            print("결제 유효성 실패")
            return false
        }
        print("결제 유효성 성공")
        return true
    }
}
