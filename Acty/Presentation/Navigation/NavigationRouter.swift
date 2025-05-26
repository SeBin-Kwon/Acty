//
//  NavigationRouter.swift
//  Acty
//
//  Created by Sebin Kwon on 5/23/25.
//

import SwiftUI

final class NavigationRouter: ObservableObject {
    @Published var authPath: [Route] = []
    @Published var tabPaths: [MainTab: [Route]] = [:]
    @Published var selectedTab: MainTab = .home
    
    init() {
        // 각 탭의 경로 배열 초기화
        MainTab.allCases.forEach { tab in
            tabPaths[tab] = []
        }
    }
    
    // 현재 탭의 경로를 반환
    var currentPath: Binding<[Route]> {
        Binding(
            get: { self.tabPaths[self.selectedTab] ?? [] },
            set: { self.tabPaths[self.selectedTab] = $0 }
        )
    }
    
    func navigate(to route: Route, in flow: RootFlow) {
        if flow == .auth {
            authPath.append(route)
        } else if flow == .main {
            tabPaths[selectedTab, default: []].append(route)
        }
    }
    
    func navigateBack(in flow: RootFlow) {
        if flow == .auth {
            if !authPath.isEmpty {
                authPath.removeLast()
            }
        } else if flow == .main && !tabPaths[selectedTab, default: []].isEmpty {
            tabPaths[selectedTab]?.removeLast()
        }
    }
    
    func navigateToRoot(in flow: RootFlow) {
        if flow == .auth {
            authPath.removeAll()
        } else if flow == .main {
            tabPaths[selectedTab]?.removeAll()
        }
    }
    
    func resetAllTabs() {
        tabPaths.keys.forEach { tab in
            tabPaths[tab] = []
        }
        selectedTab = .home
    }
}
