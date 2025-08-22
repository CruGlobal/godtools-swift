//
//  OptInNotificationUserDefaultsCache.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationUserDefaultsCache {

    enum Key: String, CaseIterable {
        case lastPrompted = "lastPromptedOptInNotification"
        case promptedCount = "optInNotificationPromptCount"
    }
    
    static let dateFormat: String = "MM/dd/yyyy"

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = OptInNotificationUserDefaultsCache.dateFormat
        return formatter
    }()
    
    private let userDefaultsCache: UserDefaultsCacheInterface

    init(userDefaultsCache: UserDefaultsCacheInterface) {

        self.userDefaultsCache = userDefaultsCache
    }
    
    func deleteAllData() {
        
        let allKeys: [Key] = Key.allCases
        
        for key in allKeys {
            
            userDefaultsCache.deleteValue(
                key: key.rawValue
            )
        }
        
        userDefaultsCache.commitChanges()
    }

    func getLastPrompted() -> Date? {
       
        guard let lastPrompted = userDefaultsCache.getValue(key: Key.lastPrompted.rawValue) as? String else {
            return nil
        }

        guard let lastPromptedDate: Date = Self.dateFormatter.date(from: lastPrompted) else {
            assertionFailure("An error occurred while parsing \(Key.lastPrompted.rawValue) from cache")
            return nil
        }

        return lastPromptedDate
    }

    func getPromptCount() -> Int {
        
        guard let promptCount = userDefaultsCache.getValue(key: Key.promptedCount.rawValue) as? Int else {
            return 0
        }

        return promptCount
    }

    func recordPrompt() {

        let currentPromptCount = getPromptCount()
        let updatedPromptCount = currentPromptCount + 1

        let todaysDate: Date = Date()
        let stringDate: String = Self.dateFormatter.string(from: todaysDate)
        
        userDefaultsCache.cache(
            value: stringDate,
            forKey: Key.lastPrompted.rawValue
        )

        userDefaultsCache.cache(
            value: updatedPromptCount,
            forKey: Key.promptedCount.rawValue
        )

        userDefaultsCache.commitChanges()
    }
}
