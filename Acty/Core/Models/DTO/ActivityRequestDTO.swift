//
//  ActivityRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import Foundation

struct ActivityRequest {
    let country: String
    let category: String
    let next: String
    let limit: Int
    let nextCursor: String
}
