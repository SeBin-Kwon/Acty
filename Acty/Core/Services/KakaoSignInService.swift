//
//  KakaoSignInService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/17/25.
//

import Foundation
import KakaoSDKUser

final class KakaoSignInService: SignInServiceProtocol {
    
    func signIn(onSuccess: @escaping (Any) -> Void, onError: @escaping (String) -> Void) {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                // 카카오톡 앱을 통한 로그인
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    if let error = error {
                        onError("카카오톡 로그인 실패: \(error.localizedDescription)")
                    } else if let token = oauthToken {
                        // 토큰을 사용하여 서버에 로그인 요청을 보내거나 처리
                        let kakaoDTO = KakaoSignInRequestDTO(oauthToken: token.accessToken, deviceToken: "deviceToken")
                        onSuccess(kakaoDTO)
                    }
                }
            } else {
                // 카카오 계정을 통한 웹 로그인
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        onError("카카오 계정 로그인 실패: \(error.localizedDescription)")
                    } else if let token = oauthToken {
                        // 토큰을 사용하여 서버에 로그인 요청을 보내거나 처리
                        let kakaoDTO = KakaoSignInRequestDTO(oauthToken: token.accessToken, deviceToken: "deviceToken")
                        onSuccess(kakaoDTO)
                    }
                }
            }
        }
    
    func signOut() {
        UserApi.shared.logout { error in
            if let error = error {
                print("로그아웃 실패: \(error.localizedDescription)")
            } else {
                print("로그아웃 성공")
            }
        }
    }
    
    
}
