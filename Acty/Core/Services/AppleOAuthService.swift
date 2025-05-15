//
//  AppleOAuthService.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine
import AuthenticationServices


final class AppleOAuthServices: NSObject, ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    @Published var givenName: String = ""
    @Published var errorMessage: String = ""
    @Published var oauthUserData = OAuthUserData()
    
    struct Input {
        var appleLoginTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
    }
    
    override init() {
        super.init()
        transform()
    }
    
    func transform() {
        input.appleLoginTapped
            .sink { [weak self] in
                self?.signIn()
            }
            .store(in: &cancellables)
    }
    
    func signIn() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()//Apple ID 제공자를 생성
        let request = appleIDProvider.createRequest()//인증 요청을 생성
        request.requestedScopes = [.fullName, .email]//사용자로부터 전체 이름과 이메일을 요청
        
        //인증 요청을 처리할 컨트롤러를 생성
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self//이 뷰 모델을 인증 컨트롤러의 delegate로 설정
        authorizationController.presentationContextProvider = self//이 뷰 모델을 인증 컨트롤러의 프레젠테이션 컨텍스트 제공자로 설정
        authorizationController.performRequests()//인증 요청을 수행
    }
    
    func signOut() {
        // 로그아웃 로직
        print("logout")
    }
}


extension AppleOAuthServices: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    //    /// Apple ID 연동 성공 시
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {//인증 정보에 따라 다르게 처리
        case let appleIDCredential as ASAuthorizationAppleIDCredential://Apple ID 자격 증명을 처리
            
            let userIdentifier = appleIDCredential.user//사용자 식별자
            let fullName = appleIDCredential.fullName//전체 이름
            let idToken = appleIDCredential.identityToken!//idToken
            
            oauthUserData.oauthId = userIdentifier
            oauthUserData.idToken = String(data: idToken, encoding: .utf8) ?? ""
        default:
            break
        }
    
    }
    
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first else {//현재 애플리케이션에서 활성화된 첫 번째 윈도우
            fatalError("No window found")
        }
        return window
    }
    
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = "Authorization failed: \(error.localizedDescription)"
    }
}

struct OAuthUserData {
    var oauthId: String = ""
    var idToken: String = ""
}
