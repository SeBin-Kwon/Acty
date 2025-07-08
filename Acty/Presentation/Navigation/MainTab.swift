//
//  MainTab.swift
//  Acty
//
//  Created by Sebin Kwon on 5/26/25.
//

import Foundation

enum MainTab: String, CaseIterable {
    case home, search, favorite, profile
    
    var title: String { rawValue.capitalized }
    
    var icon: String {
        switch self {
        case .home: return "Home_Empty"
        case .search: return "Search"
        case .favorite: return "Keep_Empty"
        case .profile: return "Profile_Empty"
        }
    }
    
    func icon(isSelected: Bool) -> String {
        switch self {
        case .home, .favorite, .profile: icon.replacingOccurrences(of: "_Empty", with: isSelected ? "_Fill" : "_Empty")
        case .search: isSelected ? "\(icon)_Fill" : icon
        }
    }
}
