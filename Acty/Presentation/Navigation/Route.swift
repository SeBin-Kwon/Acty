//
//  Route.swift
//  Acty
//
//  Created by Sebin Kwon on 5/25/25.
//

import Foundation

enum AuthRoute: Hashable {
    case signIn
    case signUp
    case forgotPassword
    case resetPassword(email: String)
}

enum HomeRoute: Hashable {
    case feed
    case postDetail(postId: String)
    case userProfile(userId: String)
}

enum SearchRoute: Hashable {
    case searchMain
    case searchResults(query: String)
    case categoryDetail(category: String)
}

enum ActivityRoute: Hashable {
    case activityFeed
    case notifications
    case activityDetail(activityId: String)
}

enum ProfileRoute: Hashable {
    case myProfile
    case editProfile
    case settings
    case changePassword
}
