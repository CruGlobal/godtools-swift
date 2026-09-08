//
//  GetToolFilterLanguagesUseCaseTests.swift
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

private enum TestLanguageFilterCategory {
    static let articles: String = "articles"
    static let conversationStarter: String = "conversation_starter"
    static let gospel: String = "gospel"
    static let growth: String = "growth"
    static let hidden: String = "hidden_category"
    static let lessons: String = "lessons_category"
}

private enum TestLanguageFilterLanguageId {
    static let afrikaans: String = "0"
    static let czech: String = "1"
    static let english: String = "2"
    static let french: String = "3"
    static let russian: String = "4"
    static let spanish: String = "5"
    static let vietnamese: String = "6"
}

struct GetToolFilterLanguagesUseCaseTests {

    struct ToolFixture {
        let id: String
        let category: String
        let resourceType: ResourceType
        let languageCodes: [LanguageCodeDomainModel]
        let isHidden: Bool
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedAnyLanguageName: String
        let expectedLanguageNamesTranslatedInAppLanguage: [String]
    }

    struct CategoryFilterArgument {
        let filterByCategoryId: String?
        let expectedLanguageIds: [String]
    }

    struct ToolsAvailableArgument {
        let filterByCategoryId: String?
        let expectedToolsAvailableCountForAnyLanguage: Int
        let expectedToolsAvailableCountByLanguageId: [String: Int]
    }

    private let englishAnyLanguageName: String = "Any language"
    private let englishToolsAvailableText: String = "tools available"
    private let spanishAnyLanguageName: String = "Cualquier idioma"
    private let spanishToolsAvailableText: String = "herramientas disponibles"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: The languages are requested.
        Then: I expect to see the any language listed first.
        """
    )
    @MainActor func anyLanguageIsListedFirst() async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByCategoryId: nil
        )

        let anyLanguage: ToolFilterLanguageDomainModel = try #require(languages.first)

        #expect(anyLanguage.languageType == .any)
        #expect(anyLanguage.id == ToolFilterLanguageDomainModel.anyId)
        #expect(anyLanguage.languageNamePair.nameInOwnLanguage.isEmpty)
        #expect(anyLanguage.languageNamePair.nameInAppLanguage == englishAnyLanguageName)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: My app language is set.
        Then: I expect to see languages sorted by the language name translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedAnyLanguageName: "Any language",
                expectedLanguageNamesTranslatedInAppLanguage: ["Afrikaans", "Czech", "English", "French", "Spanish"]
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedAnyLanguageName: "Cualquier idioma",
                expectedLanguageNamesTranslatedInAppLanguage: ["africaans", "Checo", "Español", "Francés", "Inglés"]
            )
        ]
    )
    @MainActor func languagesAreSortedByTheLanguageNameTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: argument.appLanguage,
            filterByCategoryId: nil
        )

        let anyLanguage: ToolFilterLanguageDomainModel = try #require(languages.first)

        let languageNames: [String] = languages
            .filter({ $0.languageType == .language })
            .map({ $0.languageNamePair.nameInAppLanguage })

        #expect(anyLanguage.languageNamePair.nameInAppLanguage == argument.expectedAnyLanguageName)
        #expect(languageNames == argument.expectedLanguageNamesTranslatedInAppLanguage)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: My app language is set.
        Then: I expect to see languages translated in my app language and translated in their original language.
        """
    )
    @MainActor func languagesAreTranslatedInMyAppLanguageAndTheirOriginalLanguage() async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByCategoryId: nil
        )

        let afrikaansLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == TestLanguageFilterLanguageId.afrikaans }))
        let czechLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == TestLanguageFilterLanguageId.czech }))
        let frenchLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == TestLanguageFilterLanguageId.french }))
        let spanishLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == TestLanguageFilterLanguageId.spanish }))

        #expect(afrikaansLanguage.languageNamePair.nameInOwnLanguage == "Afrikaans")
        #expect(afrikaansLanguage.languageNamePair.nameInAppLanguage == "Afrikaans")

        #expect(czechLanguage.languageNamePair.nameInOwnLanguage == "čeština")
        #expect(czechLanguage.languageNamePair.nameInAppLanguage == "Czech")

        #expect(frenchLanguage.languageNamePair.nameInOwnLanguage == "Français")
        #expect(frenchLanguage.languageNamePair.nameInAppLanguage == "French")

        #expect(spanishLanguage.languageNamePair.nameInOwnLanguage == "Español")
        #expect(spanishLanguage.languageNamePair.nameInAppLanguage == "Spanish")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: A category filter is selected.
        Then: I expect to see only the languages that have tools available in the selected category.
        """,
        arguments: [
            CategoryFilterArgument(
                filterByCategoryId: nil,
                expectedLanguageIds: [
                    TestLanguageFilterLanguageId.afrikaans,
                    TestLanguageFilterLanguageId.czech,
                    TestLanguageFilterLanguageId.english,
                    TestLanguageFilterLanguageId.french,
                    TestLanguageFilterLanguageId.spanish
                ]
            ),
            CategoryFilterArgument(
                filterByCategoryId: TestLanguageFilterCategory.gospel,
                expectedLanguageIds: [
                    TestLanguageFilterLanguageId.english,
                    TestLanguageFilterLanguageId.french,
                    TestLanguageFilterLanguageId.spanish
                ]
            ),
            CategoryFilterArgument(
                filterByCategoryId: TestLanguageFilterCategory.growth,
                expectedLanguageIds: [
                    TestLanguageFilterLanguageId.czech,
                    TestLanguageFilterLanguageId.english,
                    TestLanguageFilterLanguageId.spanish
                ]
            ),
            CategoryFilterArgument(
                filterByCategoryId: TestLanguageFilterCategory.conversationStarter,
                expectedLanguageIds: [
                    TestLanguageFilterLanguageId.french
                ]
            ),
            CategoryFilterArgument(
                filterByCategoryId: TestLanguageFilterCategory.articles,
                expectedLanguageIds: [
                    TestLanguageFilterLanguageId.afrikaans
                ]
            )
        ]
    )
    @MainActor func languagesAreFilteredByTheSelectedCategoryFilter(argument: CategoryFilterArgument) async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByCategoryId: argument.filterByCategoryId
        )

        let languageIds: [String] = languages
            .filter({ $0.languageType == .language })
            .compactMap({ $0.languageId })
            .sorted()

        #expect(languageIds == argument.expectedLanguageIds)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: A category filter is selected.
        Then: I expect to see the number of tools available per language for the selected category.
        """,
        arguments: [
            ToolsAvailableArgument(
                filterByCategoryId: nil,
                expectedToolsAvailableCountForAnyLanguage: 6,
                expectedToolsAvailableCountByLanguageId: [
                    TestLanguageFilterLanguageId.afrikaans: 1,
                    TestLanguageFilterLanguageId.czech: 1,
                    TestLanguageFilterLanguageId.english: 3,
                    TestLanguageFilterLanguageId.french: 2,
                    TestLanguageFilterLanguageId.spanish: 2
                ]
            ),
            ToolsAvailableArgument(
                filterByCategoryId: TestLanguageFilterCategory.gospel,
                expectedToolsAvailableCountForAnyLanguage: 2,
                expectedToolsAvailableCountByLanguageId: [
                    TestLanguageFilterLanguageId.english: 2,
                    TestLanguageFilterLanguageId.french: 1,
                    TestLanguageFilterLanguageId.spanish: 1
                ]
            ),
            ToolsAvailableArgument(
                filterByCategoryId: TestLanguageFilterCategory.growth,
                expectedToolsAvailableCountForAnyLanguage: 2,
                expectedToolsAvailableCountByLanguageId: [
                    TestLanguageFilterLanguageId.czech: 1,
                    TestLanguageFilterLanguageId.english: 1,
                    TestLanguageFilterLanguageId.spanish: 1
                ]
            ),
            ToolsAvailableArgument(
                filterByCategoryId: TestLanguageFilterCategory.articles,
                expectedToolsAvailableCountForAnyLanguage: 1,
                expectedToolsAvailableCountByLanguageId: [
                    TestLanguageFilterLanguageId.afrikaans: 1
                ]
            )
        ]
    )
    @MainActor func numberOfToolsAvailablePerLanguageIsFilteredByTheSelectedCategoryFilter(argument: ToolsAvailableArgument) async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByCategoryId: argument.filterByCategoryId
        )

        let anyLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageType == .any }))

        #expect(anyLanguage.toolsAvailableCount == argument.expectedToolsAvailableCountForAnyLanguage)
        #expect(anyLanguage.toolsAvailableText == "\(englishToolsAvailableText) \(argument.expectedToolsAvailableCountForAnyLanguage)")

        for (languageId, expectedCount) in argument.expectedToolsAvailableCountByLanguageId {

            let language: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == languageId }))

            #expect(language.toolsAvailableCount == expectedCount)
            #expect(language.toolsAvailableText == "\(englishToolsAvailableText) \(expectedCount)")
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: My app language is set.
        Then: I expect to see the number of tools available per language translated in my app language.
        """
    )
    @MainActor func numberOfToolsAvailablePerLanguageIsTranslatedInMyAppLanguage() async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.spanish.value,
            filterByCategoryId: nil
        )

        let anyLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageType == .any }))
        let englishLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageId == TestLanguageFilterLanguageId.english }))

        #expect(anyLanguage.languageNamePair.nameInAppLanguage == spanishAnyLanguageName)
        #expect(anyLanguage.toolsAvailableText == "\(spanishToolsAvailableText) 6")
        #expect(englishLanguage.toolsAvailableText == "\(spanishToolsAvailableText) 3")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the tool filter languages list.
        When: Lessons and hidden tools exist.
        Then: I expect to see neither their languages nor their tools counted.
        """
    )
    @MainActor func lessonAndHiddenToolLanguagesAreNotShown() async throws {

        let languages: [ToolFilterLanguageDomainModel] = try await getLanguages(
            appLanguage: LanguageCodeDomainModel.english.value,
            filterByCategoryId: nil
        )

        let languageIds: [String] = languages
            .filter({ $0.languageType == .language })
            .compactMap({ $0.languageId })

        let anyLanguage: ToolFilterLanguageDomainModel = try #require(languages.first(where: { $0.languageType == .any }))

        #expect(!languageIds.contains(TestLanguageFilterLanguageId.russian))
        #expect(!languageIds.contains(TestLanguageFilterLanguageId.vietnamese))
        #expect(anyLanguage.toolsAvailableCount == 6)
    }
}

// MARK: - Test Helpers

extension GetToolFilterLanguagesUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getLanguages(appLanguage: AppLanguageDomainModel, filterByCategoryId: String?) async throws -> [ToolFilterLanguageDomainModel] {

        let useCase: GetToolFilterLanguagesUseCase = try getUseCase()

        var cancellables: Set<AnyCancellable> = Set()

        var languagesRef: [ToolFilterLanguageDomainModel] = Array()

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    filteredByCategory: getCategoryFilter(categoryId: filterByCategoryId)
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (languages: [ToolFilterLanguageDomainModel]) in

                    guard languagesRef.isEmpty && languages.count > 0 else {
                        return
                    }

                    languagesRef = languages

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return languagesRef
    }

    @available(iOS 17.4, *)
    private func getUseCase() throws -> GetToolFilterLanguagesUseCase {

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

        return GetToolFilterLanguagesUseCase(
            resourcesRepository: resourcesRepository,
            languagesRepository: languagesRepository,
            getToolFilterLanguage: GetToolFilterLanguage(
                resourcesRepository: resourcesRepository,
                languagesRepository: languagesRepository,
                getTranslatedLanguageName: getTranslatedLanguageName(),
                localizationServices: getLocalizationServices(),
                stringWithLocaleCount: FakeStringWithLocaleCount()
            )
        )
    }

    private func getCategoryFilter(categoryId: String?) -> ToolFilterCategoryDomainModel {

        guard let categoryId = categoryId else {
            return ToolFilterCategoryDomainModel.emptyValue
        }

        return ToolFilterCategoryDomainModel.createCategory(
            id: categoryId,
            title: "",
            toolsAvailable: ""
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.toolsFilterAnyLanguage.key: englishAnyLanguageName,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: englishToolsAvailableText
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.toolsFilterAnyLanguage.key: spanishAnyLanguageName,
                LocalizableStringKeys.toolsFilterToolsAvailable.key: spanishToolsAvailableText
            ]
        ]

        return FakeLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
    }

    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {

        return GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .afrikaans: Self.createLanguage(id: TestLanguageFilterLanguageId.afrikaans, code: .afrikaans),
            .czech: Self.createLanguage(id: TestLanguageFilterLanguageId.czech, code: .czech),
            .english: Self.createLanguage(id: TestLanguageFilterLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestLanguageFilterLanguageId.french, code: .french),
            .russian: Self.createLanguage(id: TestLanguageFilterLanguageId.russian, code: .russian),
            .spanish: Self.createLanguage(id: TestLanguageFilterLanguageId.spanish, code: .spanish),
            .vietnamese: Self.createLanguage(id: TestLanguageFilterLanguageId.vietnamese, code: .vietnamese)
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
        language.name = code.rawValue + " Name"

        return language
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(
                id: "tool-gospel-1",
                category: TestLanguageFilterCategory.gospel,
                resourceType: .tract,
                languageCodes: [.english, .french, .spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-gospel-2",
                category: TestLanguageFilterCategory.gospel,
                resourceType: .tract,
                languageCodes: [.english],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-growth-1",
                category: TestLanguageFilterCategory.growth,
                resourceType: .tract,
                languageCodes: [.english, .spanish],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-growth-2",
                category: TestLanguageFilterCategory.growth,
                resourceType: .tract,
                languageCodes: [.czech],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-conversation-starter-1",
                category: TestLanguageFilterCategory.conversationStarter,
                resourceType: .tract,
                languageCodes: [.french],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-articles-1",
                category: TestLanguageFilterCategory.articles,
                resourceType: .article,
                languageCodes: [.afrikaans],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-lesson-1",
                category: TestLanguageFilterCategory.lessons,
                resourceType: .lesson,
                languageCodes: [.russian],
                isHidden: false
            ),
            ToolFixture(
                id: "tool-hidden-1",
                category: TestLanguageFilterCategory.hidden,
                resourceType: .tract,
                languageCodes: [.vietnamese],
                isHidden: true
            )
        ]
    }
}
