//
//  InMemUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor InMemUserDefaultsCache: UserDefaultsCacheInterface {
    
    private var cache: [String: Any] = Dictionary()
    
    init() {
        
    }
    
    func getBool(key: String) -> Bool? {
        return cache[key] as? Bool
    }

    func storeBool(value: Bool?, forKey: String) {
        cache[forKey] = value
    }
    
    func getDate(key: String) -> Date? {
        return cache[key] as? Date
    }
    
    func storeDate(value: Date?, forKey: String) {
        cache[forKey] = value
    }

    func getInt(key: String) -> Int? {
        return cache[key] as? Int
    }

    func storeInt(value: Int?, forKey: String) {
        cache[forKey] = value
    }

    func getString(key: String) -> String? {
        return cache[key] as? String
    }
    
    func storeString(value: String?, forKey: String) {
        cache[forKey] = value
    }
    
    func deleteValue(key: String) {
        cache[key] = nil
    }
    
    func commitChanges() {
        // Nothing needed todo here.
    }
}
