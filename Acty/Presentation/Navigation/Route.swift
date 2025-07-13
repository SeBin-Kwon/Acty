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
    case chatList
    case chat(userId: String)
    
    // Search
    case search
    
    // Activity
    case activityDetails(detailId: String)
    
    // Profile
    case myProfile, editProfile, settings
}
