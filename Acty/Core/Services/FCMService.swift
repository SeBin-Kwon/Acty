//
//  FCMService.swift
//  Acty
//
//  Created by Sebin Kwon on 6/14/25.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import Combine

protocol FCMServiceProtocol {
    var deviceToken: String? { get }
    var fcmToken: String? { get }
    var tokenDidChange: PassthroughSubject<String, Never> { get }
    
    func configure()
    func requestNotificationPermission() async -> Bool
    func updateToken()
}

final class FCMService: NSObject, FCMServiceProtocol {
    static let shared = FCMService()
    
    @Published private(set) var deviceToken: String?
    @Published private(set) var fcmToken: String?
    
    let tokenDidChange = PassthroughSubject<String, Never>()
    
    private override init() {
        super.init()
    }
    
    func configure() {
        print("🔥 FCMService 설정 시작")
        
        // FCM 델리게이트 설정
        Messaging.messaging().delegate = self
        
        // 알림 델리게이트 설정
        UNUserNotificationCenter.current().delegate = self
        
        // APNs 토큰 요청 (FCM 토큰 요청은 APNs 토큰 설정 후에 자동으로 발생)
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        // FCM 토큰은 APNs 토큰이 설정된 후 자동으로 생성됨
        // updateToken() 호출을 제거하여 타이밍 이슈 방지
        
        print("🔥 FCMService 설정 완료")
    }
    
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            print("📱 알림 권한 요청 결과: \(granted)")
            return granted
        } catch {
            print("❌ 알림 권한 요청 실패: \(error)")
            return false
        }
    }
    
    func updateToken() {
        print("🔄 FCM 토큰 업데이트 시작")
        
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("❌ FCM 토큰 가져오기 실패: \(error)")
            } else if let token = token {
                print("✅ FCM 토큰 획득 성공")
                print("🔑 FCM 토큰: \(token)")
                self?.fcmToken = token
                self?.tokenDidChange.send(token)
            }
        }
    }
}

extension FCMService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("🔄 FCM 토큰 갱신됨")
        
        if let token = fcmToken {
            print("🔑 새로운 FCM 토큰: \(token)")
            self.fcmToken = token
            tokenDidChange.send(token)
        }
    }
}

extension FCMService: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드에 있을 때 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("📱 포그라운드 알림 수신:")
        print("   제목: \(notification.request.content.title)")
        print("   내용: \(notification.request.content.body)")
        print("   데이터: \(userInfo)")
        
        // 포그라운드에서도 알림을 표시 (iOS 14+)
        completionHandler([.banner, .badge, .sound])
    }
    
    // 알림을 탭했을 때 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 알림 탭됨:")
        print("   제목: \(response.notification.request.content.title)")
        print("   내용: \(response.notification.request.content.body)")
        print("   데이터: \(userInfo)")
        
        // 알림 데이터를 기반으로 적절한 화면으로 이동
        handleNotificationTap(userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
        // TODO: NavigationRouter와 연동하여 적절한 화면으로 이동
        if let route = userInfo["route"] as? String {
            print("🧭 알림을 통한 화면 이동: \(route)")
            // 예: NavigationRouter.shared.navigate(to: route)
        }
        
        if let postId = userInfo["postId"] as? String {
            print("📄 포스트 상세로 이동: \(postId)")
            // 예: NavigationRouter.shared.navigate(to: .postDetail(postId))
        }
    }
}

extension FCMService {
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("✅ APNs 등록 성공")
        print("🔑 APNs 토큰: \(tokenString)")
        
        self.deviceToken = tokenString
        
        // FCM에 APNs 토큰 설정
        Messaging.messaging().apnsToken = deviceToken
        
        // APNs 토큰 설정 후 FCM 토큰 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateToken()
        }
    }
    
    func didFailToRegisterForRemoteNotifications(with error: Error) {
        print("❌ APNs 등록 실패: \(error)")
        print("💡 해결 방법:")
        print("   1. 실제 기기에서 테스트하고 있는지 확인")
        print("   2. Push Notifications Capability가 추가되어 있는지 확인")
        print("   3. 프로비저닝 프로파일에 Push 권한이 포함되어 있는지 확인")
    }
}

extension FCMService {
    // 로컬 알림 테스트
    func sendTestLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "테스트 알림"
        content.body = "FCM 설정이 올바르게 되었습니다!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 로컬 알림 실패: \(error)")
            } else {
                print("✅ 로컬 알림 예약됨 (2초 후 발송)")
            }
        }
    }
}
