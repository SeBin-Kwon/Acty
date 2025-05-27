//
//  NavigationRouter.swift
//  Acty
//
//  Created by Sebin Kwon on 5/23/25.
//

import SwiftUI

final class NavigationRouter: ObservableObject {
    @Published var authPath = NavigationPath()
    @Published var tabPaths: [MainTab: NavigationPath] = [:]
    @Published var selectedTab: MainTab = .home
    
    init() {
        // 각 탭의 경로를 NavigationPath로 초기화
        MainTab.allCases.forEach { tab in
            tabPaths[tab] = NavigationPath()
        }
    }
    
    // 현재 탭의 경로를 반환
    var currentPath: Binding<NavigationPath> {
        Binding(
            get: { self.tabPaths[self.selectedTab] ?? NavigationPath() },
            set: { self.tabPaths[self.selectedTab] = $0 }
        )
    }
    
    func navigate(to route: Route, in flow: RootFlow) {
        if flow == .auth {
            authPath.append(route)
        } else if flow == .main {
            tabPaths[selectedTab, default: NavigationPath()].append(route)
        }
    }
    
    func navigateBack(in flow: RootFlow) {
        if flow == .auth {
            if !authPath.isEmpty {
                authPath.removeLast()
            }
        } else if flow == .main && !tabPaths[selectedTab, default: NavigationPath()].isEmpty {
            tabPaths[selectedTab]?.removeLast()
        }
    }
    
    func navigateToRoot(in flow: RootFlow) {
        if flow == .auth {
            authPath = NavigationPath()
        } else if flow == .main {
            tabPaths[selectedTab] = NavigationPath()
        }
    }
    
    func resetAllTabs() {
        tabPaths.keys.forEach { tab in
            tabPaths[tab] = NavigationPath()
        }
        selectedTab = .home
    }
}
