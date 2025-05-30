//
//  RootView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/26/25.
//

import SwiftUI

struct RootView: View {
    @StateObject private var rootRouter = RootRouter()
    @StateObject private var navigationRouter = NavigationRouter()
    @EnvironmentObject var diContainer: DIContainer
    
    var body: some View {
        Group {
            switch rootRouter.currentFlow {
            case .splash:
                SplashView()
                    .task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await checkAuthenticationAndNavigate()
                    }
                
            case .auth:
                NavigationStack(path: $navigationRouter.authPath) {
                    SignInView(viewModel: diContainer.makeSignInViewModel())
                        .navigationDestination(for: Route.self) { route in
                            authDestinationView(for: route)
                        }
                }
                
            case .main:
                TabbarView()
            }
        }
        .environmentObject(rootRouter)
        .environmentObject(navigationRouter)
        .animation(.easeInOut, value: rootRouter.currentFlow)
        .onReceive(diContainer.authService.isAuthenticated) { isAuthenticated in
                    withAnimation {
                        rootRouter.currentFlow = isAuthenticated ? .main : .auth
                    }
                }
    }
    
    private func checkAuthenticationAndNavigate() async {
        print("스플래시: 인증 상태 체크 시작")
        
        let isAuthenticated = await diContainer.authService.checkAuthenticationStatus()
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                if isAuthenticated {
                    print("스플래시: 인증됨 -> 메인으로 이동")
                    rootRouter.currentFlow = .main
                } else {
                    print("스플래시: 미인증 -> 로그인으로 이동")
                    rootRouter.currentFlow = .auth
                }
            }
        }
    }
    
    @ViewBuilder
    private func authDestinationView(for route: Route) -> some View {
        switch route {
        case .signIn:
            SignInView(viewModel: diContainer.makeSignInViewModel())
        case .signUp:
            SignUpView(viewModel: diContainer.makeSignUpViewModel())
        default:
            EmptyView()
        }
    }
}

//#Preview {
//    RootView()
//        .environmentObject(DIContainer.shared)
//}
