//
//  LastAuthenticatedMethodCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LastAuthenticatedMethodCache {
    
    private static let lastAuthMethodCacheKey: String = "LastAuthenticatedMethodCache.lastAuthMethodCacheKey"
    
    private let userDefaultsCache: SharedUserDefaultsCache
    
    init(userDefaultsCache: SharedUserDefaultsCache) {
        
        self.userDefaultsCache = userDefaultsCache
    }

    func getLastAuthenticatedMethod() -> AuthenticationMethod? {
        
        guard let rawValue = userDefaultsCache.getValue(key: LastAuthenticatedMethodCache.lastAuthMethodCacheKey) as? String else {
            return nil
        }
        
        guard let method = AuthenticationMethod(rawValue: rawValue) else {
            return nil
        }
        
        return method
    }
    
    func store(method: AuthenticationMethod) {
        
        userDefaultsCache.cache(value: method.rawValue, forKey: LastAuthenticatedMethodCache.lastAuthMethodCacheKey)
        userDefaultsCache.commitChanges()
    }
    
    func deleteLastAuthenticationMethod() {
        
        userDefaultsCache.cache(value: nil, forKey: LastAuthenticatedMethodCache.lastAuthMethodCacheKey)
        userDefaultsCache.commitChanges()
    }
}
