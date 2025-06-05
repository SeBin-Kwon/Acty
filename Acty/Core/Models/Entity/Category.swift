//
//  Category.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import Foundation

enum Category: String, CaseIterable {
    case sightseeing, tours, packages, exciting, experiences
    
    var koreaName: String {
        switch self {
        case .sightseeing: "관광"
        case .tours: "투어"
        case .packages: "패키지"
        case .exciting: "익사이팅"
        case .experiences: "체험"
        }
    }
}
