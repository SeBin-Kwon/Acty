//
//  AppError.swift
//  Acty
//
//  Created by Sebin Kwon on 5/21/25.
//

import Foundation

enum AppError: Error {
    // MARK: - 일반 오류
    case unknown
    case notImplemented
    
    // MARK: - 네트워크 오류
    case networkError(String)
    case invalidResponse
    case invalidData
    case serverError(Int, String)
    
    // MARK: - 인증 오류
    case authenticationRequired
    case invalidCredentials
    case sessionExpired
    case refreshTokenFailed
    case tokenNotFound
    
    // MARK: - 데이터 오류
    case invalidInput(String)
    case dataNotFound
    case invalidFormat(String)
    
    // MARK: - 키체인 오류
    case keychainError(KeychainManager.KeychainError)
    
    // MARK: - 채팅 오류
    case chatError
    
    // MARK: - 결제 오류
    case paymentCancelled
    case paymentProcessingFailed(String)
    case paymentValidationFailed(String)
    case invalidPaymentInfo
}


extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        // 일반 오류
        case .unknown:
            return "알 수 없는 오류가 발생했습니다."
        case .notImplemented:
            return "아직 구현되지 않은 기능입니다."
            
        // 네트워크 오류
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .invalidResponse:
            return "서버로부터 유효하지 않은 응답을 받았습니다."
        case .invalidData:
            return "서버로부터 유효하지 않은 데이터를 받았습니다."
        case .serverError(let code, let message):
            return "서버 오류 [\(code)]: \(message)"
            
        // 인증 오류
        case .authenticationRequired:
            return "이 기능을 사용하려면 로그인이 필요합니다."
        case .invalidCredentials:
            return "아이디 또는 비밀번호가 올바르지 않습니다."
        case .sessionExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .refreshTokenFailed:
            return "인증 갱신에 실패했습니다. 다시 로그인해주세요."
        case .tokenNotFound:
            return "인증 정보를 찾을 수 없습니다."
            
        // 데이터 오류
        case .invalidInput(let field):
            return "\(field)이(가) 올바르지 않습니다."
        case .dataNotFound:
            return "요청하신 데이터를 찾을 수 없습니다."
        case .invalidFormat(let detail):
            return "잘못된 형식입니다: \(detail)"
            
        // 키체인 오류
        case .keychainError(let error):
            switch error {
            case .duplicateEntry:
                return "키체인에 중복된 항목이 있습니다."
            case .notFound:
                return "키체인에서 항목을 찾을 수 없습니다."
            case .unexpectedData:
                return "키체인에서 예상치 못한 데이터가 발견되었습니다."
            case .unknown:
                return "키체인 접근 중 알 수 없는 오류가 발생했습니다."
            }
        case .chatError:
            return "채팅을 보낼 수 없습니다."
            
        // 결제 오류
        case .paymentCancelled:
            return "결제가 취소되었습니다."
        case .paymentProcessingFailed(let message):
            return "결제 처리 중 오류가 발생했습니다: \(message)"
        case .paymentValidationFailed(let message):
            return "결제 검증 중 오류가 발생했습니다: \(message)"
        case .invalidPaymentInfo:
            return "결제 정보가 올바르지 않습니다."
        }
    }
}

// API 오류 코드를 AppError로 변환
extension AppError {
    static func mapAPIError(_ statusCode: Int, message: String? = nil) -> AppError {
        switch statusCode {
        case 400:
            return .invalidInput(message ?? "잘못된 요청입니다.")
        case 401:
            return .authenticationRequired
        case 403:
            return .invalidCredentials
        case 404:
            return .dataNotFound
        case 500...599:
            return .serverError(statusCode, message ?? "서버 오류가 발생했습니다.")
        default:
            return .networkError(message ?? "알 수 없는 네트워크 오류가 발생했습니다.")
        }
    }
}
