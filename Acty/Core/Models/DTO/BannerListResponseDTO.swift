//
//  BannerListResponseDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/20/25.
//

import Foundation

struct BannerListResponseDTO: Decodable {
    let data: [BannerDTO]
}

struct BannerDTO: Decodable {
    let name: String
    let imageUrl: String
    let payload: PayloadDTO
}

struct PayloadDTO: Decodable {
    let type: String
    let value: String
}
