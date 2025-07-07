//
//  ChatRequestDTO.swift
//  Acty
//
//  Created by Sebin Kwon on 7/6/25.
//

import Foundation

struct ChatRequestDTO: Codable {
    let content: String
    let files: [ChatFiles]
}

struct ChatFiles: Codable {
    let url: String
}


