//
//  CardJumpUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class CardJumpUserDefaultsCache {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private var didShowCardJumpKey: String {
        return "CardJumpUserDefaultsCache.didShowCardJumpKey"
    }
    
    var didShowCardJump: Bool {
        if let value = userDefaultsCache.getValue(key: didShowCardJumpKey) as? Bool {
            return value
        }
        return false
    }
    
    func cacheDidShowCardJump() {
        userDefaultsCache.cache(value: true, forKey: didShowCardJumpKey)
        userDefaultsCache.commitChanges()
    }
}
