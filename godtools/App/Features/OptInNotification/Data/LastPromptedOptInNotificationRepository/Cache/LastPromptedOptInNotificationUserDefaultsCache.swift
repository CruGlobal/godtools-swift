//
//  LastPromptedOptInNotificationUserDefaultsCache.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class LastPromptedOptInNotificationUserDefaultsCache {

    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let lastPromptedCacheKey: String = "lastPromptedOptInNotification"

    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {

        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }

    func getLastPrompted() -> String? {
        guard
            let lastPrompted = sharedUserDefaultsCache.getValue(
                key: lastPromptedCacheKey) as? String

        else {
            return nil
        }
        print("Last prompted: \(lastPrompted)")
        return lastPrompted
    }

    func recordLastPrompted(dateString: String) {
        sharedUserDefaultsCache.cache(
            value: dateString, forKey: lastPromptedCacheKey)
        sharedUserDefaultsCache.commitChanges()
    }

}
