//
//  SharedUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class SharedUserDefaultsCache: UserDefaultsCacheInterface {
    
    private let userDefaults: UserDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    func deleteValue(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func getValue(key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    func cache(value: Any?, forKey: String) {
        userDefaults.set(value, forKey: forKey)
    }
    
    func commitChanges() {
        userDefaults.synchronize()
    }
}
