//
//  SharedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor SharedUserDefaultsCache: UserDefaultsCacheInterface {
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    private func getValue(key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    private func cache(value: Any?, forKey: String) {
        userDefaults.set(value, forKey: forKey)
    }
    
    func getBool(key: String) -> Bool? {
        return getValue(key: key) as? Bool
    }

    func storeBool(value: Bool?, forKey: String) {
        cache(value: value, forKey: forKey)
    }
    
    func getDate(key: String) -> Date? {
        return getValue(key: key) as? Date
    }
    
    func storeDate(value: Date?, forKey: String) {
        cache(value: value, forKey: forKey)
    }

    func getInt(key: String) -> Int? {
        return getValue(key: key) as? Int
    }

    func storeInt(value: Int?, forKey: String) {
        cache(value: value, forKey: forKey)
    }

    func getString(key: String) -> String? {
        return getValue(key: key) as? String
    }
    
    func storeString(value: String?, forKey: String) {
        cache(value: value, forKey: forKey)
    }
    
    func deleteValue(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func commitChanges() {
        userDefaults.synchronize()
    }
}
