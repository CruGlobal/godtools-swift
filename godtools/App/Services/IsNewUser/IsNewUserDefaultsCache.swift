//
//  IsNewUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class IsNewUserDefaultsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    
    required init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
    
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    private var keyIsNewUser: String {
        return "key.newUsersDefaultCache.isNewUser"
    }
    
    var isNewUser: Bool {
        if let newUserValue = sharedUserDefaultsCache.getValue(key: keyIsNewUser) as? Bool {
            return newUserValue
        }
        return false
    }
    
    func cacheIsNewUser(isNewUser: Bool) {
        sharedUserDefaultsCache.cache(value: isNewUser, forKey: keyIsNewUser)
        sharedUserDefaultsCache.commitChanges()
    }
}
