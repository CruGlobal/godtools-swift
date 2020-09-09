//
//  CardJumpUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class CardJumpUserDefaultsCache {
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    
    required init(sharedUserDefaultsCache: SharedUserDefaultsCache) {
        
        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    private var didShowCardJumpKey: String {
        return "CardJumpUserDefaultsCache.didShowCardJumpKey"
    }
    
    var didShowCardJump: Bool {
        if let value = sharedUserDefaultsCache.getValue(key: didShowCardJumpKey) as? Bool {
            return value
        }
        return false
    }
    
    func cacheDidShowCardJump() {
        sharedUserDefaultsCache.cache(value: true, forKey: didShowCardJumpKey)
        sharedUserDefaultsCache.commitChanges()
    }
}
