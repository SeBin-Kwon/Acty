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
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
                KakaoSDK.initSDK(appKey: appKey)
            }
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
                    if url.scheme == "acty-payment" {
                        handlePaymentReturn(url: url)
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
    
    private func handlePaymentReturn(url: URL) {
        print("결제 완료 후 앱으로 돌아옴: \(url)")
        // 여기에 결제 결과 처리 로직 추가
        
        // URL에서 결제 결과 파라미터 추출
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems
        
        // 예시: acty-payment://result?status=success&orderId=12345
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
