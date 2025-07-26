//
//  WebViewRepresentable.swift
//  Acty
//
//  Created by Sebin Kwon on 7/21/25.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    let url: String
    let toastManager: ToastManager
    
    func makeUIView(context: Context) -> WKWebView {
        let coordinator = context.coordinator
        
        // 1. 메시지 핸들러 설정
        let userContentController = WKUserContentController()
        userContentController.add(coordinator, name: "click_attendance_button")
        userContentController.add(coordinator, name: "complete_attendance")
        
        // 2. WKWebView 설정
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = coordinator
        
        // 3. 헤더에 SeSACKey 추가해서 URL 로드
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            request.setValue(API_KEY, forHTTPHeaderField: "SeSACKey")
            webView.load(request)
        }
        
        coordinator.toastManager = toastManager
        // 4. coordinator에 webView 참조 전달
        coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 업데이트 로직 (필요시)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
}

// MARK: - 웹뷰 브릿지 처리 Coordinator
class WebViewCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    weak var webView: WKWebView?
    var toastManager: ToastManager?
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "click_attendance_button")
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "complete_attendance")
    }
    
    // 웹에서 앱으로 메시지 수신
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("📨 웹에서 메시지 수신: \(message.name)")
        
        switch message.name {
        case "click_attendance_button":
            handleAttendanceButtonClick()
            
        case "complete_attendance":
            handleAttendanceComplete(message: message)
            
        default:
            print("⚠️ 알 수 없는 메시지: \(message.name)")
        }
    }
    
    // 출석 버튼 클릭 처리
    private func handleAttendanceButtonClick() {
        print("🎯 출석 버튼 클릭됨 - 액세스 토큰 전송")
        
        // 액세스 토큰 가져오기 (TokenService 사용)
        do {
            let tokenService = DIContainer.shared.tokenService
            let accessToken = try tokenService.getAccessToken()
            
            // 웹으로 액세스 토큰 전송
            let jsCode = "requestAttendance('\(accessToken)')"
            webView?.evaluateJavaScript(jsCode) { result, error in
                if let error = error {
                    print("❌ JavaScript 실행 실패: \(error)")
                } else {
                    print("✅ 액세스 토큰 전송 완료")
                }
            }
            
        } catch {
            print("❌ 액세스 토큰 가져오기 실패: \(error)")
            
            // 토큰이 없으면 빈 문자열이나 에러 처리
            let jsCode = "requestAttendance('')"
            webView?.evaluateJavaScript(jsCode, completionHandler: nil)
        }
    }
    
    // 출석 완료 처리
    private func handleAttendanceComplete(message: WKScriptMessage) {        
        // 출석 횟수 확인
        if let attendanceCount = message.body as? Int {
            print("📊 출석 횟수: \(attendanceCount)회")
            
            // 출석 완료 알림이나 액션 (선택사항)
            DispatchQueue.main.async {
                // 예: 토스트 메시지, 알럿, 뒤로가기 등
                self.toastManager?.showToast(message: "🎉 \(attendanceCount)번째 출석 완료!", isSuccess: true)
                print("🎊 \(attendanceCount)번째 출석 완료!")
            }
        }
    }
    
    // 웹뷰 네비게이션 delegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ 웹뷰 로드 완료")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ 웹뷰 로드 실패: \(error)")
    }
}
