//
//  PortonePaymentRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/19/25.
//

import Foundation

struct PortonePaymentRequestDTO {
    let orderCode: String
    let merchantUid: String
    let amount: String
    let orderName: String
    let buyerName: String
    let payMethod: String
    let pgProvider: String
}
