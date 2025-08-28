//
//  UserDefaultsManager.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    struct Keys {
        static let currentUser = "current_user"
        static let searchHistory = "SearchHistory"
        static let hasBeenLaunchedBefore = "hasBeenLaunchedBeforeFlag"
    }
    
    // MARK: - Generic Methods
    func save<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            print("❌ UserDefaults 저장 실패 - key: \(key), error: \(error)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("❌ UserDefaults 로드 실패 - key: \(key), error: \(error)")
            return nil
        }
    }
    
    // MARK: - String Array Methods
    func saveStringArray(_ array: [String], forKey key: String) {
        userDefaults.set(array, forKey: key)
    }
    
    func loadStringArray(forKey key: String) -> [String]? {
        return userDefaults.array(forKey: key) as? [String]
    }
    
    // MARK: - Common Methods
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func exists(forKey key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
}

// MARK: - First Launch Detection
extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserDefaultsManager.Keys.hasBeenLaunchedBefore)
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: UserDefaultsManager.Keys.hasBeenLaunchedBefore)
        }
        return isFirstLaunch
    }
}
