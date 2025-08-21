//
//  MockSharedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class MockSharedUserDefaultsCache: UserDefaultsCacheInterface {
    
    private var userDefaults: [String: Any] = Dictionary()
    
    init() {
        
    }
    
    func deleteValue(key: String) {
        userDefaults[key] = nil
    }
    
    func getValue(key: String) -> Any? {
        return userDefaults[key]
    }
    
    func cache(value: Any?, forKey: String) {
        return userDefaults[forKey] = value
    }
    
    func commitChanges() {
        
    }
}
