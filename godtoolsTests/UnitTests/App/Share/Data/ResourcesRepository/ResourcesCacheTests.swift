//
//  ResourcesCacheTests.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import SwiftData
import RepositorySync

struct ResourcesCacheTests {

    private static let metatoolId: String = "metatool_0"

    struct ResourceFixture {

        let id: String
        let abbreviation: String
        let resourceType: ResourceType
        let category: String
        let defaultOrder: Int
        let isHidden: Bool
        let isSpotlight: Bool
        let metatoolId: String?
        let languageCodes: [LanguageCodeDomainModel]

        init(
            id: String,
            abbreviation: String,
            resourceType: ResourceType,
            category: String = "",
            defaultOrder: Int,
            isHidden: Bool = false,
            isSpotlight: Bool = false,
            metatoolId: String? = nil,
            languageCodes: [LanguageCodeDomainModel]
        ) {

            self.id = id
            self.abbreviation = abbreviation
            self.resourceType = resourceType
            self.category = category
            self.defaultOrder = defaultOrder
            self.isHidden = isHidden
            self.isSpotlight = isSpotlight
            self.metatoolId = metatoolId
            self.languageCodes = languageCodes
        }
    }

    struct LessonsByLanguageArgument {

        let languageCode: LanguageCodeDomainModel?
        let expectedLessonIds: [String]
    }

    // MARK: - Resources

    @available(iOS 17.4, *)
    @Test
    func getResources() async throws {

        let cache = try getCache()

        let resources: [ResourceDataModel] = try await cache.getResources(sorted: false)

        #expect(resources.count == getResourceFixtures().count)
    }

    @available(iOS 17.4, *)
    @Test
    func getResourcesSortedByDefaultOrder() async throws {

        let cache = try getCache()

        let resources: [ResourceDataModel] = try await cache.getResources(sorted: true)

        let expectedResourceIds: [String] = getResourceFixtures()
            .sorted { $0.defaultOrder < $1.defaultOrder }
            .map { $0.id }

        #expect(resources.map { $0.id } == expectedResourceIds)
    }

    @available(iOS 17.4, *)
    @Test
    func getResourceByAbbreviationExists() async throws {

        let cache = try getCache()

        let resource: ResourceDataModel? = try cache.getResource(abbreviation: "kgp")

        #expect(resource?.id == "tract_0")
    }

    @available(iOS 17.4, *)
    @Test
    func getResourceByAbbreviationIsNil() async throws {

        let cache = try getCache()

        let resource: ResourceDataModel? = try cache.getResource(abbreviation: "abbreviation_does_not_exist")

        #expect(resource == nil)
    }

    @available(iOS 17.4, *)
    @Test
    func getResourceVariantsExcludesHiddenVariants() async throws {

        let cache = try getCache()

        let variants: [ResourceDataModel] = try await cache.getResourceVariants(resourceId: Self.metatoolId)

        #expect(variants.map { $0.id }.sorted() == ["variant_0", "variant_1"])
    }

    @available(iOS 17.4, *)
    @Test
    func getResourceVariantsIsEmptyWhenResourceIsNotAMetatool() async throws {

        let cache = try getCache()

        let variants: [ResourceDataModel] = try await cache.getResourceVariants(resourceId: "tract_0")

        #expect(variants.isEmpty)
    }

    // MARK: - Lessons

    @available(iOS 17.4, *)
    @Test(arguments: [
        LessonsByLanguageArgument(languageCode: nil, expectedLessonIds: ["lesson_0", "lesson_1", "lesson_3", "lesson_4"]),
        LessonsByLanguageArgument(languageCode: .english, expectedLessonIds: ["lesson_0", "lesson_1", "lesson_3"]),
        LessonsByLanguageArgument(languageCode: .spanish, expectedLessonIds: ["lesson_1", "lesson_3"]),
        LessonsByLanguageArgument(languageCode: .vietnamese, expectedLessonIds: ["lesson_4"])
    ])
    func getLessonsExcludesHiddenLessons(argument: LessonsByLanguageArgument) async throws {

        let cache = try getCache()

        let lessons: [ResourceDataModel] = try await cache.getLessons(
            filterByLanguageId: argument.languageCode.map { getLanguageId(languageCode: $0) },
            sorted: false
        )

        #expect(lessons.map { $0.id }.sorted() == argument.expectedLessonIds)
    }

    @available(iOS 17.4, *)
    @Test(arguments: [
        LessonsByLanguageArgument(languageCode: nil, expectedLessonIds: ["lesson_0", "lesson_1", "lesson_3", "lesson_4"]),
        LessonsByLanguageArgument(languageCode: .english, expectedLessonIds: ["lesson_0", "lesson_1", "lesson_3"]),
        LessonsByLanguageArgument(languageCode: .spanish, expectedLessonIds: ["lesson_1", "lesson_3"]),
        LessonsByLanguageArgument(languageCode: .vietnamese, expectedLessonIds: ["lesson_4"])
    ])
    func getLessonsCount(argument: LessonsByLanguageArgument) async throws {

        let cache = try getCache()

        let lessonsCount: Int = try cache.getLessonsCount(
            filterByLanguageId: argument.languageCode.map { getLanguageId(languageCode: $0) }
        )

        #expect(lessonsCount == argument.expectedLessonIds.count)
    }

    @available(iOS 17.4, *)
    @Test
    func getLessonsSortedByDefaultOrder() async throws {

        let cache = try getCache()

        let lessons: [ResourceDataModel] = try await cache.getLessons(filterByLanguageId: nil, sorted: true)

        #expect(lessons.map { $0.id } == ["lesson_0", "lesson_1", "lesson_3", "lesson_4"])
    }

    @available(iOS 17.4, *)
    @Test
    func getFeaturedLessons() async throws {

        let cache = try getCache()

        let featuredLessons: [ResourceDataModel] = try await cache.getFeaturedLessons(sorted: true)

        #expect(featuredLessons.map { $0.id } == ["lesson_3", "lesson_4"])
    }

    @available(iOS 17.4, *)
    @Test
    func getLessonsSupportedLanguageIds() async throws {

        let cache = try getCache()

        let languageIds: [String] = try cache.getLessonsSupportedLanguageIds()

        let expectedLanguageIds: Set<String> = Set(
            [LanguageCodeDomainModel.english, .spanish, .vietnamese].map { getLanguageId(languageCode: $0) }
        )

        #expect(Set(languageIds) == expectedLanguageIds)
    }

    // MARK: - Spotlight Tools

    @available(iOS 17.4, *)
    @Test
    func getSpotlightToolsExcludesLessonsAndHiddenTools() async throws {

        let cache = try getCache()

        let spotlightTools: [ResourceDataModel] = try cache.getSpotlightTools(sortByDefaultOrder: true)

        #expect(spotlightTools.map { $0.id } == ["tract_0", "tract_2", "article_0"])
    }

    @available(iOS 17.4, *)
    @Test
    func getSpotlightToolsUnsorted() async throws {

        let cache = try getCache()

        let spotlightTools: [ResourceDataModel] = try cache.getSpotlightTools(sortByDefaultOrder: false)

        #expect(spotlightTools.map { $0.id }.sorted() == ["article_0", "tract_0", "tract_2"])
    }

    // MARK: - All Tools List

    @available(iOS 17.4, *)
    @Test
    func getAllToolsListExcludesLessonsMetatoolsAndHiddenTools() async throws {

        let cache = try getCache()

        let tools: [ResourceDataModel] = try cache.getAllToolsList(filterByCategory: nil, filterByLanguageId: nil, sortByDefaultOrder: true)

        #expect(tools.map { $0.id } == ["tract_0", "tract_1", "tract_2", "article_0", "variant_0", "variant_1"])
    }

    @available(iOS 17.4, *)
    @Test
    func getAllToolsListFilteredByCategoryAndLanguage() async throws {

        let cache = try getCache()

        let gospelToolsCount: Int = try cache.getAllToolsListCount(filterByCategory: "gospel", filterByLanguageId: nil)

        let spanishGospelToolsCount: Int = try cache.getAllToolsListCount(
            filterByCategory: "gospel",
            filterByLanguageId: getLanguageId(languageCode: .spanish)
        )

        #expect(gospelToolsCount == 5)
        #expect(spanishGospelToolsCount == 1)
    }

    @available(iOS 17.4, *)
    @Test
    func getAllToolCategoryIds() async throws {

        let cache = try getCache()

        let categoryIds: [String] = try cache.getAllToolCategoryIds(filteredByLanguageId: nil)

        #expect(Set(categoryIds) == ["gospel", "conversation_starter"])
    }

    @available(iOS 17.4, *)
    @Test
    func getAllToolLanguageIds() async throws {

        let cache = try getCache()

        let allLanguageIds: [String] = try cache.getAllToolLanguageIds(filteredByCategoryId: nil)

        let conversationStarterLanguageIds: [String] = try cache.getAllToolLanguageIds(filteredByCategoryId: "conversation_starter")

        let expectedAllLanguageIds: Set<String> = Set(
            [LanguageCodeDomainModel.english, .spanish, .vietnamese].map { getLanguageId(languageCode: $0) }
        )

        let expectedConversationStarterLanguageIds: Set<String> = Set(
            [LanguageCodeDomainModel.english, .vietnamese].map { getLanguageId(languageCode: $0) }
        )

        #expect(Set(allLanguageIds) == expectedAllLanguageIds)
        #expect(Set(conversationStarterLanguageIds) == expectedConversationStarterLanguageIds)
    }
}

// MARK: - Test Helpers

extension ResourcesCacheTests {

    @available(iOS 17.4, *)
    private func getCache() throws -> ResourcesCache {

        let testsAppConfig = TestsAppConfig(
            swiftDatabase: try FakeSwiftDatabase.createSwiftDatabase(addObjects: getSwiftDatabaseObjects())
        )

        let testsDiContainer = TestsDiContainer(testsAppConfig: testsAppConfig)

        return testsDiContainer.core.dataLayer.getResourcesCache()
    }

    private func getLanguageId(languageCode: LanguageCodeDomainModel) -> String {
        return "language_" + languageCode.rawValue
    }

    private func getLanguageCodables() -> [LanguageCodable] {

        return [LanguageCodeDomainModel.english, .spanish, .vietnamese].map { languageCode in

            LanguageCodable.random(
                id: getLanguageId(languageCode: languageCode),
                code: languageCode.rawValue,
                forceLanguageName: false
            )
        }
    }

    private func getResourceCodable(fixture: ResourceFixture) -> ResourceCodable {

        return ResourceCodable.random(
            id: fixture.id,
            abbreviation: fixture.abbreviation,
            attrCategory: fixture.category,
            attrDefaultOrder: fixture.defaultOrder,
            attrSpotlight: fixture.isSpotlight,
            isHidden: fixture.isHidden,
            metatoolId: fixture.metatoolId,
            resourceType: fixture.resourceType.rawValue
        )
    }

    private func getResourceFixtures() -> [ResourceFixture] {

        return [
            ResourceFixture(id: "lesson_0", abbreviation: "lesson_0", resourceType: .lesson, defaultOrder: 0, languageCodes: [.english]),
            ResourceFixture(id: "lesson_1", abbreviation: "lesson_1", resourceType: .lesson, defaultOrder: 1, languageCodes: [.english, .spanish]),
            ResourceFixture(id: "lesson_2", abbreviation: "lesson_2", resourceType: .lesson, defaultOrder: 2, isHidden: true, languageCodes: [.english]),
            ResourceFixture(id: "lesson_3", abbreviation: "lesson_3", resourceType: .lesson, defaultOrder: 3, isSpotlight: true, languageCodes: [.english, .spanish]),
            ResourceFixture(id: "lesson_4", abbreviation: "lesson_4", resourceType: .lesson, defaultOrder: 4, isSpotlight: true, languageCodes: [.vietnamese]),

            ResourceFixture(id: "tract_0", abbreviation: "kgp", resourceType: .tract, category: "gospel", defaultOrder: 10, isSpotlight: true, languageCodes: [.english, .spanish]),
            ResourceFixture(id: "tract_1", abbreviation: "fourlaws", resourceType: .tract, category: "gospel", defaultOrder: 11, languageCodes: [.english]),
            ResourceFixture(id: "tract_2", abbreviation: "teachme", resourceType: .tract, category: "conversation_starter", defaultOrder: 12, isSpotlight: true, languageCodes: [.english, .vietnamese]),
            ResourceFixture(id: "tract_3", abbreviation: "hidden_tract", resourceType: .tract, category: "gospel", defaultOrder: 13, isHidden: true, isSpotlight: true, languageCodes: [.english]),
            ResourceFixture(id: "article_0", abbreviation: "article", resourceType: .article, category: "gospel", defaultOrder: 14, isSpotlight: true, languageCodes: [.english]),

            ResourceFixture(id: Self.metatoolId, abbreviation: "metatool", resourceType: .metaTool, defaultOrder: 20, languageCodes: [.english]),
            ResourceFixture(id: "variant_0", abbreviation: "variant_0", resourceType: .tract, category: "gospel", defaultOrder: 21, metatoolId: Self.metatoolId, languageCodes: [.english]),
            ResourceFixture(id: "variant_1", abbreviation: "variant_1", resourceType: .tract, category: "gospel", defaultOrder: 22, metatoolId: Self.metatoolId, languageCodes: [.english]),
            ResourceFixture(id: "variant_2", abbreviation: "variant_2", resourceType: .tract, category: "gospel", defaultOrder: 23, isHidden: true, metatoolId: Self.metatoolId, languageCodes: [.english])
        ]
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [SwiftResource] {

        var languagesByCode: [String: SwiftLanguage] = Dictionary()

        for languageCodable in getLanguageCodables() {
            languagesByCode[languageCodable.code] = SwiftLanguage.createNewFrom(model: languageCodable.toModel())
        }

        return getResourceFixtures().map { fixture in

            let resource = SwiftResource.createNewFrom(
                model: getResourceCodable(fixture: fixture).toModel()
            )

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode.rawValue] else {
                    continue
                }

                resource.addLanguage(language: language)
            }

            return resource
        }
    }
}
