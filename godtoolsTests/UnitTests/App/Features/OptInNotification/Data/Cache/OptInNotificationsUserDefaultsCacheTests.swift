//
//  OptInNotificationUserDefaultsCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools

struct OptInNotificationUserDefaultsCacheTests {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    @Test(
        """
        Given: The opt in notification prompt has never been recorded.
        When: A prompt is recorded.
        Then: The prompt count should be 1 and the last prompted date should be today.
        """
    )
    func firstRecordedPromptStoresPromptCountAndLastPromptedDate() async {

        let cache: OptInNotificationUserDefaultsCache = getCache()

        await cache.recordPrompt()

        let todaysStringDate: String = Self.dateFormatter.string(from: Date())

        let lastPromptedStringDate: String?

        if let lastPromptedDate = await cache.getLastPrompted() {
            lastPromptedStringDate = Self.dateFormatter.string(from: lastPromptedDate)
        }
        else {
            lastPromptedStringDate = nil
        }

        let promptCount: Int = await cache.getPromptCount()

        #expect(promptCount == 1)
        #expect(todaysStringDate == lastPromptedStringDate)
    }

    @Test(
        """
        Given: The opt in notification prompt has been recorded once.
        When: A second prompt is recorded.
        Then: The prompt count should be 2.
        """
    )
    func secondRecordedPromptIncrementsPromptCount() async {

        let cache: OptInNotificationUserDefaultsCache = getCache()

        await cache.recordPrompt()
        await cache.recordPrompt()

        let promptCount: Int = await cache.getPromptCount()

        #expect(promptCount == 2)
    }

    @Test(
        """
        Given: The opt in notification prompt has been recorded.
        When: All data is deleted.
        Then: The prompt count should be 0 and the last prompted date should be nil.
        """
    )
    func deletingAllDataRemovesPromptCountAndLastPromptedDate() async {

        let cache: OptInNotificationUserDefaultsCache = getCache()

        await cache.recordPrompt()

        let promptCountAfterRecordingPrompt: Int = await cache.getPromptCount()
        let lastPromptedAfterRecordingPrompt: Date? = await cache.getLastPrompted()

        #expect(promptCountAfterRecordingPrompt == 1)
        #expect(lastPromptedAfterRecordingPrompt != nil)

        await cache.deleteAllData()

        let promptCountAfterDeletingAllData: Int = await cache.getPromptCount()
        let lastPromptedAfterDeletingAllData: Date? = await cache.getLastPrompted()

        #expect(promptCountAfterDeletingAllData == 0)
        #expect(lastPromptedAfterDeletingAllData == nil)
    }
}

extension OptInNotificationUserDefaultsCacheTests {

    private func getCache() -> OptInNotificationUserDefaultsCache {

        return OptInNotificationUserDefaultsCache(userDefaultsCache: InMemUserDefaultsCache())
    }
}
