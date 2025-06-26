//
//  PaymentHistoryResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/26/25.
//

import Foundation

struct PaymentHistoryResponseDTO: Codable {
    let impUid: String
    let merchantUid: String
    let payMethod: String
    let channel: String
    let pgProvider: String
    let embPgProvider: String
    let pgTid: String
    let pgId: String
    let escrow: Bool
    let applyNum: String
    let bankCode: String
    let bankName: String
    let cardCode: String
    let cardName: String
    let cardIssuerCode: String
    let cardIssuerName: String
    let cardPublisherCode: String
    let cardPublisherName: String
    let cardQuota: Int
    let cardNumber: String
    let cardType: Int
    let vbankCode: String
    let vbankName: String
    let vbankNum: String
    let vbankHolder: String
    let vbankDate: Int
    let vbankIssuedAt: Int
    let name: String
    let amount: Int
    let currency: String
    let buyerName: String
    let buyerEmail: String
    let buyerTel: String
    let buyerAddr: String
    let buyerPostcode: String
    let customData: String
    let userAgent: String
    let status: String
    let startedAt: String
    let paidAt: String
    let receiptUrl: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case impUid = "imp_uid"
        case merchantUid = "merchant_uid"
        case payMethod = "pay_method"
        case channel
        case pgProvider = "pg_provider"
        case embPgProvider = "emb_pg_provider"
        case pgTid = "pg_tid"
        case pgId = "pg_id"
        case escrow
        case applyNum = "apply_num"
        case bankCode = "bank_code"
        case bankName = "bank_name"
        case cardCode = "card_code"
        case cardName = "card_name"
        case cardIssuerCode = "card_issuer_code"
        case cardIssuerName = "card_issuer_name"
        case cardPublisherCode = "card_publisher_code"
        case cardPublisherName = "card_publisher_name"
        case cardQuota = "card_quota"
        case cardNumber = "card_number"
        case cardType = "card_type"
        case vbankCode = "vbank_code"
        case vbankName = "vbank_name"
        case vbankNum = "vbank_num"
        case vbankHolder = "vbank_holder"
        case vbankDate = "vbank_date"
        case vbankIssuedAt = "vbank_issued_at"
        case name, amount, currency
        case buyerName = "buyer_name"
        case buyerEmail = "buyer_email"
        case buyerTel = "buyer_tel"
        case buyerAddr = "buyer_addr"
        case buyerPostcode = "buyer_postcode"
        case customData = "custom_data"
        case userAgent = "user_agent"
        case status
        case startedAt = "startedAt"
        case paidAt = "paidAt"
        case receiptUrl = "receipt_url"
        case createdAt, updatedAt
    }
}
