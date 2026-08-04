//
//  GetUserToolFilterCategoryUseCaseTests.swift
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

private enum TestUserFilterCategory {
    static let articles: String = "articles"
    static let gospel: String = "gospel"
    static let growth: String = "growth"
    static let noToolsAvailable: String = "no_tools_available_category"
}

struct GetUserToolFilterCategoryUseCaseTests {

    struct ToolFixture {
        let id: String
        let category: String
        let resourceType: ResourceType
    }

    struct TestDependencies {
        let resourcesRepository: ResourcesRepository
        let userToolFiltersRepository: UserToolFiltersRepository
    }

    struct StoredCategoryArgument {
        let storedCategoryId: String
        let expectedTitle: String
        let expectedToolsAvailableCount: Int
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedAnyCategoryTitle: String
        let expectedGospelTitle: String
        let expectedToolsAvailableText: String
    }

    private let englishAnyCategoryTitle: String = "Any category"
    private let englishToolsAvailableText: String = "tools available"
    private let spanishAnyCategoryTitle: String = "Cualquier categoría"
    private let spanishToolsAvailableText: String = "herramientas disponibles"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a tools filter category.
        When: The user's tools filter category is requested.
        Then: I expect to see the any category with all tools available.
        """
    )
    @MainActor func anyCategoryIsReturnedWhenUserHasNotSelectedACategory() async throws {

        let category: ToolFilterCategoryDomainModel = try await getUserToolFilterCategory(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeCategoryId: nil
        )

        #expect(category.categoryType == .any)
        #expect(category.filterId == nil)
        #expect(category.title == englishAnyCategoryTitle)
        #expect(category.toolsAvailable == "\(englishToolsAvailableText) 4")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a tools filter category.
        When: The user's tools filter category is requested.
        Then: I expect to see the selected category with the number of tools available in that category.
        """,
        arguments: [
            StoredCategoryArgument(
                storedCategoryId: TestUserFilterCategory.gospel,
                expectedTitle: "Gospel",
                expectedToolsAvailableCount: 2
            ),
            StoredCategoryArgument(
                storedCategoryId: TestUserFilterCategory.growth,
                expectedTitle: "Growth",
                expectedToolsAvailableCount: 1
            ),
            StoredCategoryArgument(
                storedCategoryId: TestUserFilterCategory.articles,
                expectedTitle: "Articles",
                expectedToolsAvailableCount: 1
            )
        ]
    )
    @MainActor func selectedCategoryIsReturnedWhenUserHasSelectedACategory(argument: StoredCategoryArgument) async throws {

        let category: ToolFilterCategoryDomainModel = try await getUserToolFilterCategory(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeCategoryId: argument.storedCategoryId
        )

        #expect(category.categoryType == .category)
        #expect(category.filterId == argument.storedCategoryId)
        #expect(category.title == argument.expectedTitle)
        #expect(category.toolsAvailable == "\(englishToolsAvailableText) \(argument.expectedToolsAvailableCount)")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a tools filter category that no longer has tools available.
        When: The user's tools filter category is requested.
        Then: I expect to see the selected category with no tools available rather than the any category.
        """
    )
    @MainActor func selectedCategoryIsReturnedWhenItNoLongerHasToolsAvailable() async throws {

        let category: ToolFilterCategoryDomainModel = try await getUserToolFilterCategory(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeCategoryId: TestUserFilterCategory.noToolsAvailable
        )

        #expect(category.categoryType == .category)
        #expect(category.filterId == TestUserFilterCategory.noToolsAvailable)
        #expect(category.title == "Unavailable category")
        #expect(category.toolsAvailable == "\(englishToolsAvailableText) 0")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their selected tools filter category.
        When: My app language is set.
        Then: I expect to see the category title and number of tools available translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedAnyCategoryTitle: "Any category",
                expectedGospelTitle: "Gospel",
                expectedToolsAvailableText: "tools available"
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedAnyCategoryTitle: "Cualquier categoría",
                expectedGospelTitle: "Evangelio",
                expectedToolsAvailableText: "herramientas disponibles"
            )
        ]
    )
    @MainActor func categoryIsTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let anyCategory: ToolFilterCategoryDomainModel = try await getUserToolFilterCategory(
            appLanguage: argument.appLanguage,
            storeCategoryId: nil
        )

        let gospelCategory: ToolFilterCategoryDomainModel = try await getUserToolFilterCategory(
            appLanguage: argument.appLanguage,
            storeCategoryId: TestUserFilterCategory.gospel
        )

        #expect(anyCategory.title == argument.expectedAnyCategoryTitle)
        #expect(anyCategory.toolsAvailable == "\(argument.expectedToolsAvailableText) 4")

        #expect(gospelCategory.title == argument.expectedGospelTitle)
        #expect(gospelCategory.toolsAvailable == "\(argument.expectedToolsAvailableText) 2")
    }
}

// MARK: - Test Helpers

extension GetUserToolFilterCategoryUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getUserToolFilterCategory(appLanguage: AppLanguageDomainModel, storeCategoryId: String?) async throws -> ToolFilterCategoryDomainModel {

        let dependencies: TestDependencies = try getTestDependencies()

        if let storeCategoryId = storeCategoryId {
            try await dependencies.userToolFiltersRepository.storeUserCategoryFilter(categoryId: storeCategoryId)
        }

        let useCase = GetUserToolFilterCategoryUseCase(
            userToolFiltersRepository: dependencies.userToolFiltersRepository,
            getToolFilterCategory: getToolFilterCategory(resourcesRepository: dependencies.resourcesRepository)
        )

        var cancellables: Set<AnyCancellable> = Set()

        var categoryRef: ToolFilterCategoryDomainModel?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink { (category: ToolFilterCategoryDomainModel) in

                    guard categoryRef == nil else {
                        return
                    }

                    categoryRef = category

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        return try #require(categoryRef)
    }

    @available(iOS 17.4, *)
    private func getTestDependencies() throws -> TestDependencies {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer: TestsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        return TestDependencies(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            userToolFiltersRepository: testsDiContainer.feature.toolsFilter.dataLayer.getUserToolFiltersRepository()
        )
    }

    private func getToolFilterCategory(resourcesRepository: ResourcesRepository) -> GetToolFilterCategory {

        return GetToolFilterCategory(
            resourcesRepository: resourcesRepository,
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: FakeStringWithLocaleCount()
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices(localizableStrings: [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.toolsFilterAnyCategory.key: englishAnyCategoryTitle,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: englishToolsAvailableText,
                "tool_category_\(TestUserFilterCategory.articles)": "Articles",
                "tool_category_\(TestUserFilterCategory.gospel)": "Gospel",
                "tool_category_\(TestUserFilterCategory.growth)": "Growth",
                "tool_category_\(TestUserFilterCategory.noToolsAvailable)": "Unavailable category"
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.toolsFilterAnyCategory.key: spanishAnyCategoryTitle,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: spanishToolsAvailableText,
                "tool_category_\(TestUserFilterCategory.articles)": "Artículos",
                "tool_category_\(TestUserFilterCategory.gospel)": "Evangelio",
                "tool_category_\(TestUserFilterCategory.growth)": "Crecimiento",
                "tool_category_\(TestUserFilterCategory.noToolsAvailable)": "Categoría no disponible"
            ]
        ])
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        return allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.attrCategory = fixture.category
            resource.resourceType = fixture.resourceType.rawValue

            return resource
        }
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(id: "tool-gospel-1", category: TestUserFilterCategory.gospel, resourceType: .tract),
            ToolFixture(id: "tool-gospel-2", category: TestUserFilterCategory.gospel, resourceType: .tract),
            ToolFixture(id: "tool-growth-1", category: TestUserFilterCategory.growth, resourceType: .tract),
            ToolFixture(id: "tool-articles-1", category: TestUserFilterCategory.articles, resourceType: .article)
        ]
    }
}
