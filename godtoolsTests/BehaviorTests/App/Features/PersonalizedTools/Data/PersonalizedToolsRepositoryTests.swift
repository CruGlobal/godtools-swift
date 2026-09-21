//
//  PersonalizedToolsRepositoryTests.swift
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

private enum TestPersonalizedToolsRepositoryId {
    static let defaultOrderEnglish: String = "default_order_en"
    static let rankedUnitedStatesEnglish: String = "ranked_us_en"
}

struct PersonalizedToolsRepositoryTests {

    struct ResourceFixture {
        let id: String
        let resourceType: ResourceType
    }

    struct TestDependencies {
        let cache: PersonalizedToolsCache
        let repository: PersonalizedToolsRepository
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: Personalized tools have never been cached for my language.
        When: Personalized tools are requested for the first time.
        Then: I expect to see the tools that were just synced rather than an empty list.
        """
    )
    func toolsSyncedOnTheFirstRequestAreReturnedByThatSameRequest() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let cachedBeforeRequest: PersonalizedToolsDataModel? = try dependencies.cache.persistence.getDataModel(
            id: TestPersonalizedToolsRepositoryId.defaultOrderEnglish
        )

        let tools: [ResourceDataModel] = try await dependencies.repository.getTools(
            requestPriority: .high,
            type: .defaultOrder(language: LanguageCodeDomainModel.english.value),
            resourceTypes: nil,
            sortByResponse: true
        )

        #expect(cachedBeforeRequest == nil)
        #expect(tools.map({ $0.id }) == ["tool-2", "lesson-1", "tool-1"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: Personalized tools have never been cached for my country and language.
        When: Ranked tools are requested for the first time and filtered to lessons.
        Then: I expect to see only the lessons that were just synced, in the order the api returned them.
        """
    )
    func rankedLessonsSyncedOnTheFirstRequestAreReturnedInApiOrder() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let lessons: [ResourceDataModel] = try await dependencies.repository.getTools(
            requestPriority: .high,
            type: .ranked(country: "us", language: LanguageCodeDomainModel.english.value),
            resourceTypes: [.lesson],
            sortByResponse: true
        )

        #expect(lessons.map({ $0.id }) == ["lesson-2", "lesson-1"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: The api returns no personalized tools for my language.
        When: Personalized tools are requested for the first time.
        Then: I expect to see an empty list.
        """
    )
    func anEmptyListIsReturnedWhenTheApiHasNoToolsForTheRequestedType() async throws {

        let dependencies: TestDependencies = try getTestDependencies()

        let tools: [ResourceDataModel] = try await dependencies.repository.getTools(
            requestPriority: .high,
            type: .defaultOrder(language: LanguageCodeDomainModel.french.value),
            resourceTypes: nil,
            sortByResponse: true
        )

        #expect(tools.isEmpty)
    }
}

// MARK: - Test Helpers

extension PersonalizedToolsRepositoryTests {

    @available(iOS 17.4, *)
    private func getTestDependencies() throws -> TestDependencies {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let cache = PersonalizedToolsCache(
            persistence: SwiftRepositorySyncPersistence(
                database: swiftDatabase,
                mapping: SwiftPersonalizedToolsMapping()
            )
        )

        let repository = PersonalizedToolsRepository(
            cache: cache,
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            sync: PersonalizedToolsSync(
                api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
                cache: cache,
                syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
            )
        )

        return TestDependencies(
            cache: cache,
            repository: repository
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        return allResources.map { (fixture: ResourceFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.resourceType = fixture.resourceType.rawValue

            return resource
        }
    }

    private var resourceIdsByPersonalizedToolsId: [String: [String]] {

        return [
            TestPersonalizedToolsRepositoryId.defaultOrderEnglish: ["tool-2", "lesson-1", "tool-1"],
            TestPersonalizedToolsRepositoryId.rankedUnitedStatesEnglish: ["lesson-2", "tool-1", "lesson-1"]
        ]
    }

    private var allResources: [ResourceFixture] {

        return [
            ResourceFixture(id: "tool-1", resourceType: .tract),
            ResourceFixture(id: "tool-2", resourceType: .tract),
            ResourceFixture(id: "lesson-1", resourceType: .lesson),
            ResourceFixture(id: "lesson-2", resourceType: .lesson)
        ]
    }
}
