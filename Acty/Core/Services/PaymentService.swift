//
//  PaymentService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/19/25.
//

import Foundation
import iamport_ios

protocol PaymentServiceProtocol {
    func createIamportPayment(from request: PortonePaymentRequestDTO) -> IamportPayment
    func processPaymentResult(_ response: IamportResponse) -> PortonePaymentResponseDTO
    func validatePayment(impUid: String, orderCode: String) async throws -> PaymentValidationResponseDTO
    }
}

final class PaymentService: PaymentServiceProtocol {
    
    // 포트원 결제 객체 생성
    func createIamportPayment(from request: PortonePaymentRequestDTO) -> IamportPayment {
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"), // 테스트용
            merchant_uid: request.orderCode, // 서버에서 받은 order_code
            amount: request.amount
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = request.orderName
            $0.buyer_name = request.buyerName
            $0.app_scheme = "acty-payment"
        }
    }
    
    // 포트원 결제 응답을 앱 내부 DTO로 변환
    func processPaymentResult(_ response: IamportResponse) -> PortonePaymentResponseDTO {
        return PortonePaymentResponseDTO(
            success: response.success ?? false,
            merchantUid: response.merchant_uid ?? "",
            impUid: response.imp_uid,
            errorCode: response.error_code,
            errorMsg: response.error_msg
        )
    }
    
    func validatePayment(impUid: String, orderCode: String) async throws -> PaymentValidationResponseDTO {
//            let request = PaymentValidationRequestDTO(
//                impUid: impUid,
//                orderCode: orderCode
//            )
//            
//            print("=== 결제 검증 요청 ===")
//            print("imp_uid: \(impUid)")
//            print("order_code: \(orderCode)")
//            print("===================")
//            
//            let response: PaymentValidationResponseDTO = try await networkManager.fetchResults(
//                api: OrdersEndPoint.paymentValidation(impUid) as any EndPoint
//            )
//            
//            print("=== 결제 검증 응답 ===")
//            print("isValid: \(response.isValid)")
//            print("message: \(response.message ?? "")")
//            if let paymentInfo = response.paymentInfo {
//                print("amount: \(paymentInfo.amount)")
//                print("status: \(paymentInfo.status)")
//            }
//            print("===================")
//            
//            return response
//        }
}
