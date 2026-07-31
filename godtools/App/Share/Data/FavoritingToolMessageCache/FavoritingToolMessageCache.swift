//
//  FavoritingToolMessageCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class FavoritingToolMessageCache: Sendable {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
        
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private var disabledKey: String {
        return "FavoritingToolMessageCache.disabledKey"
    }
    
    var favoritingToolMessageDisabled: Bool {
        get async {
            let disabled: Bool? = await userDefaultsCache.getBool(key: disabledKey)
            return disabled ?? false
        }
    }
    
    func disableFavoritingToolMessage() async {
        
        await userDefaultsCache.storeBool(value: true, forKey: disabledKey)
        await userDefaultsCache.commitChanges()
    }
}
