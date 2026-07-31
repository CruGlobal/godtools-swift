//
//  LastAuthenticatedProviderCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class LastAuthenticatedProviderCache: Sendable {
    
    private static let lastAuthenticatedProviderCacheKey: String = "LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey"
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }

    func getLastAuthenticatedProvider() async -> AuthenticationProviderType? {

        guard let rawValue = await userDefaultsCache.getString(key: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey) else {
            return nil
        }

        guard let provider = AuthenticationProviderType(rawValue: rawValue) else {
            return nil
        }

        return provider
    }

    func store(provider: AuthenticationProviderType) async {

        await userDefaultsCache.storeString(value: provider.rawValue, forKey: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey)
        await userDefaultsCache.commitChanges()
    }

    func deleteLastAuthenticatedProvider() async {

        await userDefaultsCache.storeString(value: nil, forKey: LastAuthenticatedProviderCache.lastAuthenticatedProviderCacheKey)
        await userDefaultsCache.commitChanges()
    }
}
