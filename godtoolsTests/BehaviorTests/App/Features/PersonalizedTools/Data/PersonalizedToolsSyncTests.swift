//
//  PersonalizedToolsSyncTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 9/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
import Combine
@testable import godtools
import SwiftData
import RepositorySync

private enum TestPersonalizedToolsSyncId {
    static let defaultOrderEnglish: String = "default_order_en"
    static let featuredUnitedStatesEnglish: String = "featured_us_en"
    static let rankedUnitedStatesEnglish: String = "ranked_us_en"
}

private enum TestCacheObservation {
    static let windowNanoseconds: UInt64 = 500_000_000
}

@MainActor private final class ChangeCounter {

    private(set) var count: Int = 0

    func increment() {
        count += 1
    }
}

struct PersonalizedToolsSyncTests {

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a country, which is stored as either no country or an empty iso region code.
        When: Personalized tools are synced.
        Then: I expect the default order tools to sync without the country specific requests being attempted.
        """,
        arguments: [nil, ""] as [String?]
    )
    func onlyDefaultOrderSyncsWhenNoCountryIsSelected(country: String?) async throws {

        let cache: PersonalizedToolsCache = try getCache()

        let sync = PersonalizedToolsSync(
            api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
            cache: cache,
            syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
        )

        try await sync.sync(
            requestPriority: .high,
            country: country,
            language: LanguageCodeDomainModel.english.value,
            forceNewSync: true
        )

        let defaultOrder: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: TestPersonalizedToolsSyncId.defaultOrderEnglish
        )

        let featured: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: TestPersonalizedToolsSyncId.featuredUnitedStatesEnglish
        )

        let ranked: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: TestPersonalizedToolsSyncId.rankedUnitedStatesEnglish
        )

        #expect(defaultOrder?.resourceIds == ["tool-1", "tool-2"])
        #expect(featured == nil)
        #expect(ranked == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: The api returns the same tools that are already cached.
        When: Personalized tools are synced again.
        Then: I expect the cache not to be rewritten, so that observers of the cache are not needlessly notified.
        """
    )
    @MainActor func anUnchangedListIsNotRewrittenToTheCache() async throws {

        let cache: PersonalizedToolsCache = try getCache()

        let sync = PersonalizedToolsSync(
            api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
            cache: cache,
            syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
        )

        try await sync.sync(
            requestPriority: .high,
            country: nil,
            language: LanguageCodeDomainModel.english.value,
            forceNewSync: true
        )

        let versionAfterFirstSync: Int? = try cache.persistence.getDataModel(
            id: TestPersonalizedToolsSyncId.defaultOrderEnglish
        )?.resourceIds.count

        let changeCounter = ChangeCounter()

        let cancellable: AnyCancellable = cache.persistence
            .observeCollectionChangesPublisher()
            .dropFirst()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { _ in

                changeCounter.increment()
            })

        try await sync.sync(
            requestPriority: .high,
            country: nil,
            language: LanguageCodeDomainModel.english.value,
            forceNewSync: true
        )

        try await Task.sleep(nanoseconds: TestCacheObservation.windowNanoseconds)

        cancellable.cancel()

        #expect(versionAfterFirstSync == 2)
        #expect(changeCounter.count == 0)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: A list of tools is already cached and the api now returns a different list.
        When: Personalized tools are synced again.
        Then: I expect the cache to be updated with the new list and observers to be notified within the same window the unchanged case checks.
        """
    )
    @MainActor func aChangedListIsWrittenToTheCache() async throws {

        let cache: PersonalizedToolsCache = try getCache()

        let firstSync = PersonalizedToolsSync(
            api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
            cache: cache,
            syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
        )

        try await firstSync.sync(
            requestPriority: .high,
            country: nil,
            language: LanguageCodeDomainModel.english.value,
            forceNewSync: true
        )

        let secondSync = PersonalizedToolsSync(
            api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: [
                TestPersonalizedToolsSyncId.defaultOrderEnglish: ["tool-3"]
            ]),
            cache: cache,
            syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
        )

        let changeCounter = ChangeCounter()

        let cancellable: AnyCancellable = cache.persistence
            .observeCollectionChangesPublisher()
            .dropFirst()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { _ in

                changeCounter.increment()
            })

        try await secondSync.sync(
            requestPriority: .high,
            country: nil,
            language: LanguageCodeDomainModel.english.value,
            forceNewSync: true
        )

        try await Task.sleep(nanoseconds: TestCacheObservation.windowNanoseconds)

        cancellable.cancel()

        let defaultOrder: PersonalizedToolsDataModel? = try cache.persistence.getDataModel(
            id: TestPersonalizedToolsSyncId.defaultOrderEnglish
        )

        #expect(defaultOrder?.resourceIds == ["tool-3"])
        #expect(changeCounter.count >= 1)
    }
}

// MARK: - Test Helpers

extension PersonalizedToolsSyncTests {

    @available(iOS 17.4, *)
    private func getCache() throws -> PersonalizedToolsCache {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        return PersonalizedToolsCache(
            persistence: SwiftRepositorySyncPersistence(
                database: swiftDatabase,
                mapping: SwiftPersonalizedToolsMapping()
            )
        )
    }

    private var resourceIdsByPersonalizedToolsId: [String: [String]] {

        return [
            TestPersonalizedToolsSyncId.defaultOrderEnglish: ["tool-1", "tool-2"],
            TestPersonalizedToolsSyncId.featuredUnitedStatesEnglish: ["tool-3"],
            TestPersonalizedToolsSyncId.rankedUnitedStatesEnglish: ["tool-2", "tool-1"]
        ]
    }
}
