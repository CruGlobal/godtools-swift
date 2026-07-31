//
//  OptInNotificationUserDefaultsCache.swift
//  godtools
//
//  Created by Jason Bennett on 3/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class OptInNotificationUserDefaultsCache: Sendable {

    enum Key: String, CaseIterable {
        case lastPrompted = "lastPromptedOptInNotification"
        case promptedCount = "optInNotificationPromptCount"
    }

    private static let dateFormat: String = "MM/dd/yyyy"
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = OptInNotificationUserDefaultsCache.dateFormat
        return formatter
    }()
    
    private let userDefaultsCache: UserDefaultsCacheInterface

    init(userDefaultsCache: UserDefaultsCacheInterface) {

        self.userDefaultsCache = userDefaultsCache
    }
    
    func deleteAllData() async {

        let allKeys: [Key] = Key.allCases

        for key in allKeys {

            await userDefaultsCache.deleteValue(
                key: key.rawValue
            )
        }

        await userDefaultsCache.commitChanges()
    }

    func getLastPrompted() async -> Date? {

        guard let lastPrompted = await userDefaultsCache.getString(key: Key.lastPrompted.rawValue) else {
            return nil
        }

        guard let lastPromptedDate: Date = Self.dateFormatter.date(from: lastPrompted) else {
            assertionFailure("An error occurred while parsing \(Key.lastPrompted.rawValue) from cache")
            return nil
        }

        return lastPromptedDate
    }

    func getPromptCount() async -> Int {

        guard let promptCount = await userDefaultsCache.getInt(key: Key.promptedCount.rawValue) else {
            return 0
        }

        return promptCount
    }

    func recordPrompt() async {

        let currentPromptCount = await getPromptCount()
        let updatedPromptCount = currentPromptCount + 1

        let todaysDate: Date = Date()
        let stringDate: String = Self.dateFormatter.string(from: todaysDate)

        await userDefaultsCache.storeString(
            value: stringDate,
            forKey: Key.lastPrompted.rawValue
        )

        await userDefaultsCache.storeInt(
            value: updatedPromptCount,
            forKey: Key.promptedCount.rawValue
        )

        await userDefaultsCache.commitChanges()
    }
}
