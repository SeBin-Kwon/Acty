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
    func processPaymentResult(_ response: IamportResponse) throws -> PortonePaymentResponseDTO
    func validatePayment(impUid: String, orderCode: String) async throws -> PaymentValidationResponseDTO
}

final class PaymentService: PaymentServiceProtocol {
    
    private let networkManager: NetworkManager
        
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
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
    func processPaymentResult(_ response: IamportResponse) throws -> PortonePaymentResponseDTO {
        let result = PortonePaymentResponseDTO(
            success: response.success ?? false,
            merchantUid: response.merchant_uid ?? "",
            impUid: response.imp_uid,
            errorCode: response.error_code,
            errorMsg: response.error_msg
        )
        
        if !result.success {
            if let errorMsg = result.errorMsg {
                throw AppError.networkError("결제 실패: \(errorMsg)")
            } else {
                throw AppError.networkError("결제 처리 중 오류가 발생했습니다")
            }
        }
        
        return result
    }
    
    func validatePayment(impUid: String, orderCode: String) async throws -> PaymentValidationResponseDTO {
        print("=== 결제 검증 요청 ===")
        print("imp_uid: \(impUid)")
        print("order_code: \(orderCode)")
        print("===================")
        
        do {
            let response: PaymentValidationResponseDTO = try await networkManager.fetchResults(
                api: OrdersEndPoint.paymentValidation(impUid) as any EndPoint
            )
            
            print("=== 결제 검증 응답 ===")
            print("isValid: \(response.paymentId)")
            print("===================")
            
            return response
        } catch let error as AppError {
            print("결제 검증 실패: AppError")
            throw error
        } catch {
            print("결제 검증 실패: \(error)")
            throw AppError.networkError("결제 검증에 실패했습니다")
        }
    }
}
