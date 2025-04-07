//
//  OptInNotificationUserDefaultsCache.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationsUserDefaultsCache {

    private let sharedUserDefaultsCache: SharedUserDefaultsCache
    private let lastPromptedCacheKey: String = "lastPromptedOptInNotification"
    private let promptCountCacheKey: String = "OptInNotificationPromptCount"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {

        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }

    func getLastPrompted() -> Date? {
        guard
            let lastPrompted = sharedUserDefaultsCache.getValue(
                key: lastPromptedCacheKey
            ) as? String

        else {
            return nil
        }

        let lastPromptedDate: Date =
            OptInNotificationsUserDefaultsCache.dateFormatter.date(
                from: lastPrompted
            ) ?? Date()

        return lastPromptedDate
    }

    func getPromptCount() -> Int {
        guard
            let promptCount = sharedUserDefaultsCache.getValue(
                key: promptCountCacheKey
            ) as? Int

        else { return 0 }

        return promptCount
    }

    func recordPrompt() {

        let currentPromptCount = getPromptCount()
        let updatedPromptCount = currentPromptCount + 1

        sharedUserDefaultsCache.cache(
            value: OptInNotificationsUserDefaultsCache.dateFormatter.string(
                from: Date()
            ),
            forKey: lastPromptedCacheKey
        )

        sharedUserDefaultsCache.cache(
            value: updatedPromptCount,
            forKey: promptCountCacheKey
        )

        sharedUserDefaultsCache.commitChanges()
    }

}
