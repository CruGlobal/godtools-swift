//
//  CardJumpUserDefaultsCache.swift
//  godtools
//
//  Created by Levi Eggert on 8/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

final class CardJumpUserDefaultsCache: Sendable {
    
    private let userDefaultsCache: UserDefaultsCacheInterface
    
    init(userDefaultsCache: UserDefaultsCacheInterface) {
        
        self.userDefaultsCache = userDefaultsCache
    }
    
    private var didShowCardJumpKey: String {
        return "CardJumpUserDefaultsCache.didShowCardJumpKey"
    }
    
    var didShowCardJump: Bool {
        get async {
            let value: Bool? = await userDefaultsCache.getBool(key: didShowCardJumpKey)
            return value ?? false
        }
    }
    
    func cacheDidShowCardJump() async {
        await userDefaultsCache.storeBool(value: true, forKey: didShowCardJumpKey)
        await userDefaultsCache.commitChanges()
    }
}
