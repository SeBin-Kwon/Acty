//
//  TabbarView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject var diContainer: DIContainer
    @EnvironmentObject var navigationRouter: NavigationRouter
    
    var body: some View {
        TabView(selection: $navigationRouter.selectedTab) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                NavigationStack(path: Binding(
                    get: { navigationRouter.tabPaths[tab] ?? NavigationPath() },
                    set: { navigationRouter.tabPaths[tab] = $0 }
                )) {
                    rootViewForTab(tab)
                        .navigationDestination(for: Route.self) { route in
                            mainDestinationView(for: route)
                        }
                }
                .tabItem {
                    Image(tab.icon(isSelected: navigationRouter.selectedTab == tab))
                        .opacity(navigationRouter.selectedTab == tab ? 1 : 0.5)
                }
                .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func rootViewForTab(_ tab: MainTab) -> some View {
        switch tab {
        case .home:
            HomeView(viewModel: diContainer.makeHomeViewModel())
        case .search:
            Text("Search")
        case .favorite:
            ChatListView()
        case .profile:
            Text("ProfileView")
        }
    }
    
    @ViewBuilder
    private func mainDestinationView(for route: Route) -> some View {
        switch route {
        case .homeFeed:
            HomeView(viewModel: diContainer.makeHomeViewModel())
        case .postDetail(let postId):
            Text("Post Detail: \(postId)")
        case .userProfile(let userId):
            Text("User Profile: \(userId)")
        case .searchMain:
            Text("Search Main")
        case .searchResults(let query):
            Text("Search Results: \(query)")
        case .categoryDetail(let category):
            Text("Category: \(category)")
        case .activityDetails(let detailId):
            DetailView(viewModel: diContainer.makeDetailViewModel(), paymentViewModel: diContainer.makePaymentViewModel(), id: detailId)
        case .chatList:
            ChatListView()
        case .chat(let userId):
            ChatView(userId: userId, viewModel: diContainer.makeChatViewModel(id: userId))
        case .myProfile:
            Text("My Profile")
        case .editProfile:
            Text("Edit Profile")
        case .settings:
            Text("Settings")
        default:
            EmptyView()
        }
    }
}

#Preview {
    TabbarView()
        .environmentObject(DIContainer.shared)
        .environmentObject(NavigationRouter())
}
