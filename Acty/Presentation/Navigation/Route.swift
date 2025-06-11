//
//  Route.swift
//  Acty
//
//  Created by Sebin Kwon on 5/25/25.
//

import Foundation

enum Route: Hashable {
    // Auth
    case signIn, signUp
    
    // Home
    case homeFeed
    case postDetail(postId: String)
    case userProfile(userId: String)
    
    // Search
    case searchMain
    case searchResults(query: String)
    case categoryDetail(category: String)
    
    // Activity
    case activityDetails(activityId: String)
    
    // Profile
    case myProfile, editProfile, settings
}
