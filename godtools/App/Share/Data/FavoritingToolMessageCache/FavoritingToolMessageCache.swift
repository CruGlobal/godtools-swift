//
//  FavoritingToolMessageCache.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritingToolMessageCache {
    
    private let userDefaultsCache: SharedUserDefaultsCache
        
    init(userDefaultsCache: SharedUserDefaultsCache) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private var disabledKey: String {
        return "FavoritingToolMessageCache.disabledKey"
    }
    
    var favoritingToolMessageDisabled: Bool {
        if let disabledValue = userDefaultsCache.getValue(key: disabledKey) as? Bool {
            return disabledValue
        }
        return false
    }
    
    func disableFavoritingToolMessage() {
        
        userDefaultsCache.cache(value: true, forKey: disabledKey)
        userDefaultsCache.commitChanges()
    }
}
