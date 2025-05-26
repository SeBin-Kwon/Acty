//
//  MainTab.swift
//  Acty
//
//  Created by Sebin Kwon on 5/26/25.
//

import Foundation

enum MainTab: String, CaseIterable {
    case home, search, activity, profile
    
    var title: String { rawValue.capitalized }
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .activity: return "heart"
        case .profile: return "person"
        }
    }
    
    func icon(isSelected: Bool) -> String {
        if self == .search || !isSelected { return icon }
        return "\(icon).fill"
    }
}
