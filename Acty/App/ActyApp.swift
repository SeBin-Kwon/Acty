//
//  ActyApp.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("🎬 프리뷰 모드 - Firebase 초기화 건너뜀")
            return true
        }
        
        print("🚀 앱 시작 - Firebase 설정 중...")
        FirebaseApp.configure()
        
        // FCM 서비스 초기화
        FCMService.shared.configure()
        
        print("✅ Firebase 및 FCM 설정 완료")
        
        return true
    }
    
    // APNs 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        FCMService.shared.didRegisterForRemoteNotifications(with: deviceToken)
    }
    
    // APNs 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        FCMService.shared.didFailToRegisterForRemoteNotifications(with: error)
    }
}

@main
struct ActyApp: App {
    
    @StateObject private var diContainer = DIContainer.shared
    @StateObject private var toastManager = ToastManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
                KakaoSDK.initSDK(appKey: appKey)
            }
        }
        
        ImagePipelineManager.configure(with: DIContainer.shared.tokenService)
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .accentColor(.accent)
                .preferredColorScheme(.light)
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                    if url.scheme == "acty-payment" {
                        handlePaymentReturn(url: url)
                    }
                })
                .environmentObject(diContainer)
                .environmentObject(toastManager)
                .task {
                    await requestNotificationPermission()
                }
        }
    }
    
    private func configureNavigationBarAppearance() {
        // 표준 appearance (스크롤 시 보이는 배경)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        
        // 스크롤 엣지 appearance (맨 위에 있을 때 투명)
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        
        let blueChevron = UIImage(systemName: "chevron.left")?.withTintColor(UIColor.accent, renderingMode: .alwaysOriginal)
        
        [standardAppearance, scrollEdgeAppearance].forEach { appearance in
            appearance.setBackIndicatorImage(blueChevron, transitionMaskImage: blueChevron)
            appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            appearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        }
        
        // 각각 다른 appearance 적용
        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }

    
    private func requestNotificationPermission() async {
        let granted = await FCMService.shared.requestNotificationPermission()
        if granted {
            print("✅ 알림 권한 허용됨")
        } else {
            print("❌ 알림 권한 거부됨")
        }
    }
    
    private func handlePaymentReturn(url: URL) {
        print("결제 완료 후 앱으로 돌아옴: \(url)")
        // 여기에 결제 결과 처리 로직 추가
        
        // URL에서 결제 결과 파라미터 추출
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        if let status = queryItems?.first(where: { $0.name == "status" })?.value {
            if status == "success" {
                // 결제 성공 처리
                print("결제 성공!")
            } else {
                // 결제 실패 처리
                print("결제 실패!")
            }
        }
    }
}
