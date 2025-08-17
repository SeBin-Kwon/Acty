//
//  SignInViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/15/25.
//

import Foundation
import Combine

final class SignInViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    private let authService: AuthServiceProtocol
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var signInTapped = PassthroughSubject<SignInType, Never>()
    }
    
    struct Output {
        var isSignIn = PassthroughSubject<Bool, Never>()
        var errorMessage = PassthroughSubject<String, Never>()
        var isLoading = PassthroughSubject<Bool, Never>()
    }
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        transform()
    }
    
    func transform() {
        input.signInTapped
            .sink { [weak self] type in
                guard let self else { return }
                self.signIn(type)
            }
            .store(in: &cancellables)
    }
    
    private func signIn(_ type: SignInType) {
        output.isLoading.send(true)
        
        Task {
            do {
                let _ = try await authService.signIn(with: type, email: input.email, password: input.password)
                
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.isSignIn.send(true)
                }
            } catch let error as AppError {
                print("\(type) 로그인 AppError: \(error)")
                
                await MainActor.run {
                    self.output.isLoading.send(false)
                    self.output.errorMessage.send(error.localizedDescription)
                    self.output.isSignIn.send(false)
                }
            } catch {
                print("\(type) 로그인 기타 오류: \(error)")
                
                await MainActor.run {
                    self.output.isLoading.send(false)
                    let appError = (error as? AppError) ?? AppError.authenticationRequired
                    self.output.errorMessage.send(appError.localizedDescription)
                    self.output.isSignIn.send(false)
                }
            }
        }
    }
}

enum SignInType {
    case email
    case apple
    case kakao
}
