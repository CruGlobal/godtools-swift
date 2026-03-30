//
//  InMemUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class InMemUserDefaultsCache: UserDefaultsCacheInterface {
    
    private var cache: [String: Any] = Dictionary()
    
    init() {
        
    }
    
    func deleteValue(key: String) {
        cache[key] = nil
    }
    
    func getValue(key: String) -> Any? {
        return cache[key]
    }
    
    func cache(value: Any?, forKey: String) {
        cache[forKey] = value
    }
    
    func commitChanges() {
        // Nothing needed todo here.
    }
}
