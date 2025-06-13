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
        
        print("🚀 앱 시작 - Firebase 설정 중...")
        FirebaseApp.configure()
        
        // FCM 서비스 초기화
        FCMService.shared.configure()
        
        print("✅ Firebase 및 FCM 설정 완료")
        
        return true
    }
    
    // APNs 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        FCMService.shared.didRegisterForRemoteNotifications(with: deviceToken)
    }
    
    // APNs 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        FCMService.shared.didFailToRegisterForRemoteNotifications(with: error)
    }
}

@main
struct ActyApp: App {
    
    @StateObject private var diContainer = DIContainer.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: appKey)
        }
        
        ImagePipelineManager.configure(with: DIContainer.shared.tokenService)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
                .environmentObject(diContainer)
                .task {
                    await requestNotificationPermission()
                }
        }
    }
    
    private func requestNotificationPermission() async {
        let granted = await FCMService.shared.requestNotificationPermission()
        if granted {
            print("✅ 알림 권한 허용됨")
        } else {
            print("❌ 알림 권한 거부됨")
        }
    }
}
