//
//  PortonePaymentResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/19/25.
//

import Foundation

struct PortonePaymentResponseDTO {
    let success: Bool
    let merchantUid: String
    let impUid: String?
    let errorCode: String?
    let errorMsg: String?
}
