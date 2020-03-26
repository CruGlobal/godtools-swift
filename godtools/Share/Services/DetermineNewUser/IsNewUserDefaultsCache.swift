//
//  IsNewUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class IsNewUserDefaultsCache: IsNewUserCacheType {
    
    required init() {
    }
    
    private var keyIsNewUser: String {
        return "key.newUsersDefaultCache.isNewUser"
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    var isNewUser: Bool {
        if let newUserValue = defaults.object(forKey: keyIsNewUser) as? Bool {
            return newUserValue
        }
        return false
    }
    
    func cacheIsNewUser(isNewUser: Bool) {
        defaults.setValue(isNewUser, forKey: keyIsNewUser)
        defaults.synchronize()
    }
}
