//
//  LastAuthenticatedProviderCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LastAuthenticatedProviderCache {
    
    private static let lastAuthenticatedProviderCacheKey: String = "LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey"
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }

    func getLastAuthenticatedProvider() -> AuthenticationProviderType? {
        
        guard let rawValue = userDefaultsCache.getValue(key: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey) as? String else {
            return nil
        }
        
        guard let provider = AuthenticationProviderType(rawValue: rawValue) else {
            return nil
        }
        
        return provider
    }
    
    func store(provider: AuthenticationProviderType) {
        
        userDefaultsCache.cache(value: provider.rawValue, forKey: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey)
        userDefaultsCache.commitChanges()
    }
    
    func deleteLastAuthenticatedProvider() {
        
        userDefaultsCache.cache(value: nil, forKey: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey)
        userDefaultsCache.commitChanges()
    }
}
