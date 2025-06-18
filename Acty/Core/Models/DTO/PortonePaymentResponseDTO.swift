//
//  PortonePaymentResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/19/25.
//

import Foundation

struct PortonePaymentResponseDTO: Codable {
    let success: Bool
    let merchantUid: String
    let impUid: String?
    let payMethod: String?
    let amount: Int?
    let status: String?
    let name: String?
    let paidAt: Int?
    let receiptUrl: String?
    let errorCode: String?
    let errorMsg: String?
    
    enum CodingKeys: String, CodingKey {
        case success, merchantUid = "merchant_uid", impUid = "imp_uid"
        case payMethod = "pay_method", amount, status, name
        case paidAt = "paid_at", receiptUrl = "receipt_url"
        case errorCode = "error_code", errorMsg = "error_msg"
    }
}
