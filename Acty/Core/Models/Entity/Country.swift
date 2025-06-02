//
//  Country.swift
//  Acty
//
//  Created by Sebin Kwon on 6/2/25.
//

import Foundation

enum Country: String, CaseIterable {
    case Korea, Japan, Australia, Philippines, Taiwan, Thailand, Argentina
    
    var koreaName: String {
        switch self {
        case .Korea: "대한민국"
        case .Japan: "일본"
        case .Australia: "호주"
        case .Philippines: "필리핀"
        case .Thailand: "태국"
        case .Taiwan: "대만"
        case .Argentina: "아르헨티나"
        }
    }
}
