//
//  SignInViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine
import KakaoSDKUser

final class SignInViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let appleSignInService: SignInServiceProtocol
    private let kakaoSignInService: SignInServiceProtocol
    private let authService: AuthServiceProtocol
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var emailSignInTapped = PassthroughSubject<Void, Never>()
        var appleSignInTapped = PassthroughSubject<Void, Never>()
        var kakaoSignInTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSignIn = PassthroughSubject<Bool, Never>()
        var errorMessage = PassthroughSubject<String, Never>()
        var isLoading = PassthroughSubject<Bool, Never>()
    }
    
    init(appleSignInService: SignInServiceProtocol, kakaoSignInService: SignInServiceProtocol, authService: AuthServiceProtocol) {
        self.appleSignInService = appleSignInService
        self.kakaoSignInService = kakaoSignInService
        self.authService = authService
        transform()
    }
    
    func transform() {
        
        input.emailSignInTapped
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.output.isLoading.send(true)
                
                Task {
                    do {
                        let dto = EmailSignInRequestDTO(email: self.input.email, password: self.input.password, deviceToken: nil)
                        let _ = try await self.authService.signIn(with: dto)
                        await MainActor.run {
                            self.output.isLoading.send(false)
                            self.output.isSignIn.send(true)
                        }
                    } catch {
                        print("이메일 로그인 오류: \(error)")
                        
                        await MainActor.run {
                            self.output.isLoading.send(false)
                            self.output.errorMessage.send("로그인 실패: \(error.localizedDescription)")
                            self.output.isSignIn.send(false)
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        input.kakaoSignInTapped
            .sink { [weak self] in
                guard let self = self else { return }
                self.kakaoSignInService.signIn(
                    onSuccess: { result in
                        if let dto = result as? KakaoSignInRequestDTO {
                            print("카카오 로그인 성공: \(dto)")
                            Task {
                                do {
                                    let _ = try await self.authService.signIn(with: dto)
                                    
                                    await MainActor.run {
                                        self.output.isLoading.send(false)
                                        self.output.isSignIn.send(true)
                                    }
                                } catch {
                                    print("카카오 로그인 서버 오류: \(error)")
                                    
                                    await MainActor.run {
                                        self.output.isLoading.send(false)
                                        self.output.errorMessage.send("서버 로그인 실패: \(error.localizedDescription)")
                                        self.output.isSignIn.send(false)
                                    }
                                }
                            }
                        }
                    },
                    onError: { error in
                        print("카카오 로그인 오류: \(error)")
                        self.output.isLoading.send(false)
                        self.output.errorMessage.send(error)
                        self.output.isSignIn.send(false)
                    }
                )
            }
            .store(in: &cancellables)
        
        input.appleSignInTapped
            .sink { [weak self] in
                guard let self else { return }
                self.appleSignInService.signIn(
                    onSuccess: { result in
                        if let dto = result as? AppleSignInRequestDTO {
                            print("애플 로그인 성공: \(dto)")
                            Task {
                            do {
                                let _ = try await self.authService.signIn(with: dto)
                                
                                await MainActor.run {
                                    self.output.isLoading.send(false)
                                    self.output.isSignIn.send(true)
                                }
                            } catch {
                                print("애플 로그인 서버 오류: \(error)")
                                
                                await MainActor.run {
                                    self.output.isLoading.send(false)
                                    self.output.errorMessage.send("서버 로그인 실패: \(error.localizedDescription)")
                                    self.output.isSignIn.send(false)
                                }
                            }
                        }
                        }
                    },
                    onError: { error in
                        print("애플 로그인 오류: \(error)")
                        self.output.isLoading.send(false)
                        self.output.errorMessage.send(error)
                        self.output.isSignIn.send(false)
                    }
                )
            }
            .store(in: &cancellables)
    }
    
    private func signIn() {
        print("")
    }
}
