//
//  ActyApp.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct ActyApp: App {
    
    @StateObject private var diContainer = DIContainer.shared
    
    init() {
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: appKey)
        }
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
        }
    }
}
