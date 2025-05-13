//
//  SignUpViewModel.swift
//  Acty
//
//  Created by Sebin Kwon on 5/13/25.
//

import Foundation
import Combine

final class SignUpViewModel: ViewModelType {
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
    
    struct Input {
        var email: String = ""
        var password: String = ""
        var nickname: String = ""
        var phoneNumber: String = ""
        var introduction: String = ""
        let signUpButtonTapped = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var isSignUp = false
    }
    
    init() {
        transform()
    }
    
    func transform() {
        input.signUpButtonTapped
            .sink { [weak self] in
                guard let self else { return }
                print(input.email, input.password, input.nickname)
                self.signUp()
            }
            .store(in: &cancellables)
    }
    
    private func validateEmail() -> Bool {
        return true
    }
    
    private func signUp() {
        Task {
            do {
                let result: SignUpResult = try await NetworkManager.shared.fetchResults(api: .signUp(SignUpRequest(email: input.email, password: input.password, nick: input.nickname)))
            } catch {
                print("오류")
            }
        }
    }
}
