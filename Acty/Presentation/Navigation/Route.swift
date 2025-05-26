//
//  Route.swift
//  Acty
//
//  Created by Sebin Kwon on 5/25/25.
//

import Foundation

enum Route: Hashable {
    case auth(AuthRoute)
    case home(HomeRoute)
    case search(SearchRoute)
    case activity(ActivityRoute)
    case profile(ProfileRoute)
}

enum AuthRoute: Hashable {
    case signIn, signUp
}

enum HomeRoute: Hashable {
    case feed, postDetail(postId: String), userProfile(userId: String)
}

enum SearchRoute: Hashable {
    case searchMain, searchResults(query: String), categoryDetail(category: String)
}

enum ActivityRoute: Hashable {
    case activityFeed, notifications, activityDetail(activityId: String)
}

enum ProfileRoute: Hashable {
    case myProfile, editProfile, settings, changePassword
}
