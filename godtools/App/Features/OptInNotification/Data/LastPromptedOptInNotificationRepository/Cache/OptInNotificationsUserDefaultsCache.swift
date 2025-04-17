//
//  OptInNotificationUserDefaultsCache.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationsUserDefaultsCache {

    enum Key: String, CaseIterable {
        case lastPrompted = "lastPromptedOptInNotification"
        case promptedCount = "optInNotificationPromptCount"
    }
    
    static let dateFormat: String = "MM/dd/yyyy"

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = OptInNotificationsUserDefaultsCache.dateFormat
        return formatter
    }()
    
    private let sharedUserDefaultsCache: SharedUserDefaultsCache

    init(sharedUserDefaultsCache: SharedUserDefaultsCache) {

        self.sharedUserDefaultsCache = sharedUserDefaultsCache
    }
    
    func deleteAllData() {
        
        let allKeys: [Key] = Key.allCases
        
        for key in allKeys {
            
            sharedUserDefaultsCache.deleteValue(
                key: key.rawValue
            )
        }
        
        sharedUserDefaultsCache.commitChanges()
    }

    func getLastPrompted() -> Date? {
       
        guard let lastPrompted = sharedUserDefaultsCache.getValue(key: Key.lastPrompted.rawValue) as? String else {
            return nil
        }

        guard let lastPromptedDate: Date = Self.dateFormatter.date(from: lastPrompted) else {
            assertionFailure("An error occurred while parsing \(Key.lastPrompted.rawValue) from cache")
            return nil
        }

        return lastPromptedDate
    }

    func getPromptCount() -> Int {
        
        guard let promptCount = sharedUserDefaultsCache.getValue(key: Key.promptedCount.rawValue) as? Int else {
            return 0
        }

        return promptCount
    }

    func recordPrompt() {

        let currentPromptCount = getPromptCount()
        let updatedPromptCount = currentPromptCount + 1

        let todaysDate: Date = Date()
        let stringDate: String = Self.dateFormatter.string(from: todaysDate)
        
        sharedUserDefaultsCache.cache(
            value: stringDate,
            forKey: Key.lastPrompted.rawValue
        )

        sharedUserDefaultsCache.cache(
            value: updatedPromptCount,
            forKey: Key.promptedCount.rawValue
        )

        sharedUserDefaultsCache.commitChanges()
    }
}
