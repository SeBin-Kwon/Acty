//
//  KeychainManager.swift
//  Acty
//
//  Created by Sebin Kwon on 5/18/25.
//

import Foundation

final class KeychainManager: Sendable {
    static let shared = KeychainManager()
    private init() {}
    
    enum KeychainError: Error {
            case duplicateEntry
            case unknown(OSStatus)
            case notFound
            case unexpectedData
        }
        
        func saveToken(token: String, for account: String) throws {
            print("KeychainManager", #function)
            let tokenData = token.data(using: .utf8)!
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecValueData as String: tokenData
            ]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecDuplicateItem {
                // 이미 존재하는 경우 업데이트
                try updateToken(token: token, for: account)
                return
            }
            
            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
        }
        
        func updateToken(token: String, for account: String) throws {
            print("KeychainManager", #function)
            let tokenData = token.data(using: .utf8)!
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: tokenData
            ]
            
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
        }
        
        func getToken(for account: String) throws -> String {
            print("KeychainManager", #function)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnData as String: true
            ]
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status == errSecSuccess else {
                throw KeychainError.unknown(status)
            }
            
            guard let tokenData = result as? Data,
                  let token = String(data: tokenData, encoding: .utf8) else {
                throw KeychainError.unexpectedData
            }
            print("토큰 가져오기")
            return token
        }
        
        func deleteToken(for account: String) throws {
            print("KeychainManager", #function)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw KeychainError.unknown(status)
            }
        }
}
