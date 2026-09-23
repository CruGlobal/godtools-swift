//
//  PersonalizedToolsSyncTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 9/21/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import SwiftData
import RepositorySync

private enum TestPersonalizedToolsSyncId {
    static let defaultOrderEnglish: String = "default_order_en"
    static let featuredUnitedStatesEnglish: String = "featured_us_en"
    static let rankedUnitedStatesEnglish: String = "ranked_us_en"
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
