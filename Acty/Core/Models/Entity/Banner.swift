//
//  Banner.swift
//  Acty
//
//  Created by Sebin Kwon on 7/20/25.
//

import Foundation

struct Banner: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageUrl: String
    let payload: Payload
    
    var fullImageURL: String {
        return BASE_URL + imageUrl
    }
    
    var fullWebURL: String {
        return "\(BASE_URL.replacingOccurrences(of: "/v1", with: ""))" + payload.value
    }
}

struct Payload: Hashable {
    let type: PayloadType
    let value: String
}

enum PayloadType: String {
    case webview = "WEBVIEW"
}


