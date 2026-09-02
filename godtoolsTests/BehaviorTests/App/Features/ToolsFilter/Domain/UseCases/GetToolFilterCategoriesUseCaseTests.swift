//
//  GetToolFilterCategoriesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/28/26.
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
    static let conversationStarter: String = "conversation_starter"
    static let gospel: String = "gospel"
    static let growth: String = "growth"
    static let hidden: String = "hidden_category"
    static let lessons: String = "lessons_category"
}

private enum TestLanguageId {
    static let english: String = "0"
    static let french: String = "1"
    static let spanish: String = "2"
}

struct GetToolFilterCategoriesUseCaseTests {

    struct ToolFixture {
        let id: String
        let category: String
        let resourceType: ResourceType
        let languageCodes: [LanguageCodeDomainModel]
        let isHidden: Bool
    }

    struct LanguageFilterArgument {
        let filterByLanguageId: String?
        let expectedCategoryIds: [String]
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedTitlesByCategoryId: [String: String]
        let expectedAnyCategoryTitle: String
    }

    struct ToolsAvailableArgument {
        let filterByLanguageId: String?
        let expectedToolsAvailableCountForAnyCategory: Int
        let expectedToolsAvailableCountByCategoryId: [String: Int]
    }

    private let englishAnyCategoryTitle: String = "Any category"
    private let englishToolsAvailableText: String = "tools available"
    private let spanishAnyCategoryTitle: String = "Cualquier categoría"
    private let spanishToolsAvailableText: String = "herramientas disponibles"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: The categories are requested.
        Then: I expect to see the any category listed first.
        """
    )
    @MainActor func anyCategoryIsListedFirst() async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByLanguageId: nil
        )

        let anyCategory: ToolFilterCategoryDomainModel = try #require(categories.first)

        #expect(anyCategory.categoryType == .any)
        #expect(anyCategory.filterId == nil)
        #expect(anyCategory.title == englishAnyCategoryTitle)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: A language filter is selected.
        Then: I expect to see only the categories that have tools available in the selected language.
        """,
        arguments: [
            LanguageFilterArgument(
                filterByLanguageId: nil,
                expectedCategoryIds: [
                    TestToolCategory.articles,
                    TestToolCategory.conversationStarter,
                    TestToolCategory.gospel,
                    TestToolCategory.growth
                ]
            ),
            LanguageFilterArgument(
                filterByLanguageId: TestLanguageId.english,
                expectedCategoryIds: [
                    TestToolCategory.gospel,
                    TestToolCategory.growth
                ]
            ),
            LanguageFilterArgument(
                filterByLanguageId: TestLanguageId.french,
                expectedCategoryIds: [
                    TestToolCategory.conversationStarter,
                    TestToolCategory.gospel
                ]
            ),
            LanguageFilterArgument(
                filterByLanguageId: TestLanguageId.spanish,
                expectedCategoryIds: [
                    TestToolCategory.articles,
                    TestToolCategory.gospel,
                    TestToolCategory.growth
                ]
            )
        ]
    )
    @MainActor func categoriesAreFilteredByTheSelectedLanguageFilter(argument: LanguageFilterArgument) async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByLanguageId: argument.filterByLanguageId
        )

        let categoryIds: [String] = categories.compactMap({ $0.filterId }).sorted()

        #expect(categoryIds == argument.expectedCategoryIds)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: My app language is set.
        Then: I expect to see the category titles translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedTitlesByCategoryId: [
                    TestToolCategory.articles: "Articles",
                    TestToolCategory.conversationStarter: "Conversation Starter",
                    TestToolCategory.gospel: "Gospel",
                    TestToolCategory.growth: "Growth"
                ],
                expectedAnyCategoryTitle: "Any category"
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedTitlesByCategoryId: [
                    TestToolCategory.articles: "Artículos",
                    TestToolCategory.conversationStarter: "Iniciador de conversación",
                    TestToolCategory.gospel: "Evangelio",
                    TestToolCategory.growth: "Crecimiento"
                ],
                expectedAnyCategoryTitle: "Cualquier categoría"
            )
        ]
    )
    @MainActor func categoryTitlesAreTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: argument.appLanguage,
            filterByLanguageId: nil
        )

        #expect(categories.first(where: { $0.categoryType == .any })?.title == argument.expectedAnyCategoryTitle)

        for (categoryId, expectedTitle) in argument.expectedTitlesByCategoryId {

            let category: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.filterId == categoryId }))

            #expect(category.title == expectedTitle)
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: A language filter is selected.
        Then: I expect to see the number of tools available per category for the selected language.
        """,
        arguments: [
            ToolsAvailableArgument(
                filterByLanguageId: nil,
                expectedToolsAvailableCountForAnyCategory: 5,
                expectedToolsAvailableCountByCategoryId: [
                    TestToolCategory.articles: 1,
                    TestToolCategory.conversationStarter: 1,
                    TestToolCategory.gospel: 2,
                    TestToolCategory.growth: 1
                ]
            ),
            ToolsAvailableArgument(
                filterByLanguageId: TestLanguageId.english,
                expectedToolsAvailableCountForAnyCategory: 3,
                expectedToolsAvailableCountByCategoryId: [
                    TestToolCategory.gospel: 2,
                    TestToolCategory.growth: 1
                ]
            ),
            ToolsAvailableArgument(
                filterByLanguageId: TestLanguageId.french,
                expectedToolsAvailableCountForAnyCategory: 2,
                expectedToolsAvailableCountByCategoryId: [
                    TestToolCategory.conversationStarter: 1,
                    TestToolCategory.gospel: 1
                ]
            ),
            ToolsAvailableArgument(
                filterByLanguageId: TestLanguageId.spanish,
                expectedToolsAvailableCountForAnyCategory: 3,
                expectedToolsAvailableCountByCategoryId: [
                    TestToolCategory.articles: 1,
                    TestToolCategory.gospel: 1,
                    TestToolCategory.growth: 1
                ]
            )
        ]
    )
    @MainActor func numberOfToolsAvailablePerCategoryIsFilteredByTheSelectedLanguageFilter(argument: ToolsAvailableArgument) async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByLanguageId: argument.filterByLanguageId
        )

        let anyCategory: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.categoryType == .any }))

        #expect(anyCategory.toolsAvailable == "\(englishToolsAvailableText) \(argument.expectedToolsAvailableCountForAnyCategory)")

        for (categoryId, expectedCount) in argument.expectedToolsAvailableCountByCategoryId {

            let category: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.filterId == categoryId }))

            #expect(category.toolsAvailable == "\(englishToolsAvailableText) \(expectedCount)")
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: My app language is set.
        Then: I expect to see the number of tools available per category translated in my app language.
        """
    )
    @MainActor func numberOfToolsAvailablePerCategoryIsTranslatedInMyAppLanguage() async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.spanish.value,
            filterByLanguageId: nil
        )

        let anyCategory: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.categoryType == .any }))
        let gospelCategory: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.filterId == TestToolCategory.gospel }))

        #expect(anyCategory.title == spanishAnyCategoryTitle)
        #expect(anyCategory.toolsAvailable == "\(spanishToolsAvailableText) 5")
        #expect(gospelCategory.toolsAvailable == "\(spanishToolsAvailableText) 2")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter categories list.
        When: Lessons and hidden tools exist.
        Then: I expect to see neither their categories nor their tools counted.
        """
    )
    @MainActor func lessonAndHiddenToolCategoriesAreNotShown() async throws {

        let categories: [ToolFilterCategoryDomainModel] = try await getCategories(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByLanguageId: nil
        )

        let categoryIds: [String] = categories.compactMap({ $0.filterId })

        let anyCategory: ToolFilterCategoryDomainModel = try #require(categories.first(where: { $0.categoryType == .any }))

        #expect(!categoryIds.contains(TestToolCategory.lessons))
        #expect(!categoryIds.contains(TestToolCategory.hidden))
        #expect(anyCategory.toolsAvailable == "\(englishToolsAvailableText) 5")
    }
}

// MARK: - Test Helpers

extension GetToolFilterCategoriesUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getCategories(appLanguage: AppLanguageDomainModel, filterByLanguageId: String?) async throws -> [ToolFilterCategoryDomainModel] {

        let useCase: GetToolFilterCategoriesUseCase = try getUseCase()

        var cancellables: Set<AnyCancellable> = Set()

        var categoriesRef: [ToolFilterCategoryDomainModel] = Array()

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    filteredByLanguage: getLanguageFilter(languageId: filterByLanguageId)
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (categories: [ToolFilterCategoryDomainModel]) in

                    guard categoriesRef.isEmpty && categories.count > 0 else {
                        return
                    }

                    categoriesRef = categories

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return categoriesRef
    }

    @available(iOS 17.4, *)
    private func getUseCase() throws -> GetToolFilterCategoriesUseCase {

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

        return GetToolFilterCategoriesUseCase(
            resourcesRepository: resourcesRepository,
            getToolFilterCategory: GetToolFilterCategory(
                resourcesRepository: resourcesRepository,
                localizationServices: getLocalizationServices(),
                stringWithLocaleCount: FakeStringWithLocaleCount()
            )
        )
    }

    private func getLanguageFilter(languageId: String?) -> ToolFilterLanguageDomainModel {

        guard let languageId = languageId else {
            return ToolFilterLanguageDomainModel.emptyValue
        }

        return ToolFilterLanguageDomainModel.createLanguage(
            id: languageId,
            languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: ""),
            toolsAvailable: "",
            numberOfToolsAvailable: 0
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices(localizableStrings: [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.toolsFilterAnyCategory.key: englishAnyCategoryTitle,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: englishToolsAvailableText,
                "tool_category_\(TestToolCategory.articles)": "Articles",
                "tool_category_\(TestToolCategory.conversationStarter)": "Conversation Starter",
                "tool_category_\(TestToolCategory.gospel)": "Gospel",
                "tool_category_\(TestToolCategory.growth)": "Growth"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.toolsFilterAnyCategory.key: spanishAnyCategoryTitle,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: spanishToolsAvailableText,
                "tool_category_\(TestToolCategory.articles)": "Artículos",
                "tool_category_\(TestToolCategory.conversationStarter)": "Iniciador de conversación",
                "tool_category_\(TestToolCategory.gospel)": "Evangelio",
                "tool_category_\(TestToolCategory.growth)": "Crecimiento"
            ]
        ])
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .english: Self.createLanguage(id: TestLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestLanguageId.french, code: .french),
            .spanish: Self.createLanguage(id: TestLanguageId.spanish, code: .spanish)
        ]

        let tools: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.attrCategory = fixture.category
            resource.resourceType = fixture.resourceType.rawValue
            resource.isHidden = fixture.isHidden

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

                resource.addLanguage(language: language)
            }

            return resource
        }

        return Array(languagesByCode.values) + tools
    }

    @available(iOS 17.4, *)
    private static func createLanguage(id: String, code: LanguageCodeDomainModel) -> SwiftLanguage {

        let language = SwiftLanguage()
        language.id = id
        language.code = code.rawValue

        return language
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(
                id: "tool-gospel-1",
                category: TestToolCategory.gospel,
                resourceType: .tract,
                languageCodes: [.english, .french, .spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-gospel-2",
                category: TestToolCategory.gospel,
                resourceType: .tract,
                languageCodes: [.english],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-growth-1",
                category: TestToolCategory.growth,
                resourceType: .tract,
                languageCodes: [.english, .spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-conversation-starter-1",
                category: TestToolCategory.conversationStarter,
                resourceType: .tract,
                languageCodes: [.french],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-articles-1",
                category: TestToolCategory.articles,
                resourceType: .article,
                languageCodes: [.spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-lesson-1",
                category: TestToolCategory.lessons,
                resourceType: .lesson,
                languageCodes: [.english, .spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-hidden-1",
                category: TestToolCategory.hidden,
                resourceType: .tract,
                languageCodes: [.english, .spanish],
                isHidden: true
            )
        ]
    }
}
