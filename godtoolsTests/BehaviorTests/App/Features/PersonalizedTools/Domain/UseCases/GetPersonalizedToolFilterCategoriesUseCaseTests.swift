//
//  GetPersonalizedToolFilterCategoriesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Jason Bennett on 11/9/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Testing
@testable import godtools
import Combine
import SwiftData
import RepositorySync

private enum TestToolCategory {
    static let articles: String = "articles"
    static let gospel: String = "gospel"
    static let training: String = "training"
}

private enum TestLanguageId {
    static let english: String = "0"
    static let french: String = "1"
}

private enum TestCountry {
    static let unitedStatesWithRankedTools: String = "us"
    static let canadaWithoutRankedTools: String = "ca"
}

struct GetPersonalizedToolFilterCategoriesUseCaseTests {

    struct ToolFixture {
        let id: String
        let category: String
        let resourceType: ResourceType
        let isHidden: Bool
    }

    struct CountryArgument {
        let country: LocalizationSettingsCountryDomainModel?
        let expectedFilterIds: [String?]
        let expectedToolsAvailable: [String]
    }

    private let englishAnyCategoryTitle: String = "Any category"
    private let englishToolsAvailableText: String = "tools available"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country that has ranked tools for their language.
        When: The personalized tool categories are requested.
        Then: I expect to see an any category with the total and each category of the visible ranked tools with its count, in the order the tools were ranked.
        """
    )
    @MainActor func categoriesAndCountsAreBuiltFromTheRankedTools() async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestCountry.unitedStatesWithRankedTools),
            filterByLanguageId: nil
        )

        #expect(categories.map({ $0.filterId }) == [nil, TestToolCategory.articles, TestToolCategory.gospel])
        #expect(categories.map({ $0.title }) == [englishAnyCategoryTitle, "Articles", "Gospel"])
        #expect(categories.map({ $0.toolsAvailable }) == ["\(englishToolsAvailableText) 4", "\(englishToolsAvailableText) 1", "\(englishToolsAvailableText) 2"])
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a country, or selected one without ranked tools, and there are default order tools for their language.
        When: The personalized tool categories are requested.
        Then: I expect to see the categories and counts of the default order tools.
        """,
        arguments: [
            CountryArgument(
                country: nil,
                expectedFilterIds: [nil, TestToolCategory.training, TestToolCategory.gospel],
                expectedToolsAvailable: ["tools available 2", "tools available 1", "tools available 1"]
            ),
            CountryArgument(
                country: LocalizationSettingsCountryDomainModel(isoRegionCode: TestCountry.canadaWithoutRankedTools),
                expectedFilterIds: [nil, TestToolCategory.training, TestToolCategory.gospel],
                expectedToolsAvailable: ["tools available 2", "tools available 1", "tools available 1"]
            )
        ]
    )
    @MainActor func categoriesAndCountsFallBackToTheDefaultOrderTools(argument: CountryArgument) async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: argument.country,
            filterByLanguageId: nil
        )

        #expect(categories.map({ $0.filterId }) == argument.expectedFilterIds)
        #expect(categories.map({ $0.toolsAvailable }) == argument.expectedToolsAvailable)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing personalized tools with English as their app language.
        When: French is selected as the tools filter language.
        Then: I expect to see the categories and counts of the tools for French rather than for my app language.
        """
    )
    @MainActor func categoriesAndCountsFollowTheSelectedFilterLanguage() async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterByLanguageId: TestLanguageId.french
        )

        #expect(categories.map({ $0.filterId }) == [nil, TestToolCategory.training])
        #expect(categories.map({ $0.toolsAvailable }) == ["\(englishToolsAvailableText) 1", "\(englishToolsAvailableText) 1"])
    }
}

// MARK: - Test Helpers

extension GetPersonalizedToolFilterCategoriesUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getCategories(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterByLanguageId: String?) async throws -> [ToolFilterCategoryDomainModel] {

        let useCase: GetPersonalizedToolFilterCategoriesUseCase = try getUseCase()

        var cancellables: Set<AnyCancellable> = Set()

        var categoriesRef: [ToolFilterCategoryDomainModel]?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    country: country,
                    filterByLanguageId: filterByLanguageId
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (categories: [ToolFilterCategoryDomainModel]) in

                    guard categoriesRef == nil else {
                        return
                    }

                    categoriesRef = categories

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(categoriesRef)
    }

    @available(iOS 17.4, *)
    private func getUseCase() throws -> GetPersonalizedToolFilterCategoriesUseCase {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let resourcesRepository: ResourcesRepository = testsDiContainer.core.dataLayer.getResourcesRepository()
        let languagesRepository: LanguagesRepository = testsDiContainer.core.dataLayer.getLanguagesRepository()

        let cache = PersonalizedToolsCache(
            persistence: SwiftRepositorySyncPersistence(
                database: swiftDatabase,
                mapping: SwiftPersonalizedToolsMapping()
            )
        )

        let personalizedToolsRepository = PersonalizedToolsRepository(
            cache: cache,
            resourcesRepository: resourcesRepository,
            sync: PersonalizedToolsSync(
                api: FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId),
                cache: cache,
                syncInvalidatorPersistence: FakeSyncInvalidatorPersistence()
            )
        )

        return GetPersonalizedToolFilterCategoriesUseCase(
            resourcesRepository: resourcesRepository,
            personalizedToolsRepository: personalizedToolsRepository,
            getPersonalizedToolResources: GetPersonalizedToolResources(personalizedToolsRepository: personalizedToolsRepository),
            getLanguageElseAppLanguage: GetLanguageElseAppLanguage(languagesRepository: languagesRepository),
            getToolFilterCategory: GetToolFilterCategory(
                resourcesRepository: resourcesRepository,
                localizationServices: getLocalizationServices(),
                stringWithLocaleCount: FakeStringWithLocaleCount()
            )
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices(localizableStrings: [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.toolsFilterAnyCategory.key: englishAnyCategoryTitle,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: englishToolsAvailableText,
                "tool_category_\(TestToolCategory.articles)": "Articles",
                "tool_category_\(TestToolCategory.gospel)": "Gospel",
                "tool_category_\(TestToolCategory.training)": "Training"
            ]
        ])
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languages: [SwiftLanguage] = [
            Self.createLanguage(id: TestLanguageId.english, code: .english),
            Self.createLanguage(id: TestLanguageId.french, code: .french)
        ]

        let resources: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.attrCategory = fixture.category
            resource.resourceType = fixture.resourceType.rawValue
            resource.isHidden = fixture.isHidden

            for language in languages {
                resource.addLanguage(language: language)
            }

            return resource
        }

        let personalizedTools: [SwiftPersonalizedTools] = resourceIdsByPersonalizedToolsId.map { (personalizedToolsId: String, resourceIds: [String]) in

            let object = SwiftPersonalizedTools()
            object.id = personalizedToolsId
            object.resourceIds = resourceIds

            return object
        }

        return languages + resources + personalizedTools
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue
        language.name = code.rawValue + " Name"

        return language
    }

    private var resourceIdsByPersonalizedToolsId: [String: [String]] {

        return [
            "ranked_us_en": ["tool-articles", "tool-hidden", "tool-gospel-1", "lesson-1", "tool-gospel-2", "tool-uncategorized"],
            "default_order_en": ["tool-training", "tool-gospel-1", "tool-hidden"],
            "default_order_fr": ["tool-training"]
        ]
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(id: "tool-gospel-1", category: TestToolCategory.gospel, resourceType: .tract, isHidden: false),
            ToolFixture(id: "tool-gospel-2", category: TestToolCategory.gospel, resourceType: .tract, isHidden: false),
            ToolFixture(id: "tool-articles", category: TestToolCategory.articles, resourceType: .article, isHidden: false),
            ToolFixture(id: "tool-training", category: TestToolCategory.training, resourceType: .tract, isHidden: false),
            ToolFixture(id: "tool-uncategorized", category: "", resourceType: .tract, isHidden: false),
            ToolFixture(id: "tool-hidden", category: TestToolCategory.gospel, resourceType: .tract, isHidden: true),
            ToolFixture(id: "lesson-1", category: TestToolCategory.gospel, resourceType: .lesson, isHidden: false)
        ]
    }
}
