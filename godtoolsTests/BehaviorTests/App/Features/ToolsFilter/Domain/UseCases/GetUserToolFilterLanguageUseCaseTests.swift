//
//  GetUserToolFilterLanguageUseCaseTests.swift
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

private enum TestUserFilterLanguageId {
    static let english: String = "0"
    static let french: String = "1"
    static let spanish: String = "2"
    static let doesNotExist: String = "999"
}

struct GetUserToolFilterLanguageUseCaseTests {

    struct ToolFixture {
        let id: String
        let languageCodes: [LanguageCodeDomainModel]
    }

    struct TestDependencies {
        let resourcesRepository: ResourcesRepository
        let languagesRepository: LanguagesRepository
        let userToolFiltersRepository: UserToolFiltersRepository
    }

    struct StoredLanguageArgument {
        let storedLanguageId: String
        let expectedLanguageName: String
        let expectedLanguageNameTranslatedInAppLanguage: String
        let expectedToolsAvailableCount: Int
    }

    struct AppLanguageArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedAnyLanguageName: String
        let expectedFrenchNameTranslatedInAppLanguage: String
        let expectedToolsAvailableText: String
    }

    private let englishAnyLanguageName: String = "Any language"
    private let englishToolsAvailableText: String = "tools available"
    private let spanishAnyLanguageName: String = "Cualquier idioma"
    private let spanishToolsAvailableText: String = "herramientas disponibles"

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a tools filter language.
        When: The user's tools filter language is requested.
        Then: I expect to see the any language with all tools available.
        """
    )
    @MainActor func anyLanguageIsReturnedWhenUserHasNotSelectedALanguage() async throws {

        let language: ToolFilterLanguageDomainModel = try await getUserToolFilterLanguage(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeLanguageId: nil
        )

        #expect(language.languageType == .any)
        #expect(language.filterId == nil)
        #expect(language.languageNamePair.nameInOwnLanguage.isEmpty)
        #expect(language.languageNamePair.nameInAppLanguage == englishAnyLanguageName)
        #expect(language.numberOfToolsAvailable == 4)
        #expect(language.toolsAvailable == "\(englishToolsAvailableText) 4")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a tools filter language.
        When: The user's tools filter language is requested.
        Then: I expect to see the selected language with the number of tools available in that language.
        """,
        arguments: [
            StoredLanguageArgument(
                storedLanguageId: TestUserFilterLanguageId.english,
                expectedLanguageName: "English",
                expectedLanguageNameTranslatedInAppLanguage: "English",
                expectedToolsAvailableCount: 3
            ),
            StoredLanguageArgument(
                storedLanguageId: TestUserFilterLanguageId.french,
                expectedLanguageName: "Français",
                expectedLanguageNameTranslatedInAppLanguage: "French",
                expectedToolsAvailableCount: 2
            ),
            StoredLanguageArgument(
                storedLanguageId: TestUserFilterLanguageId.spanish,
                expectedLanguageName: "Español",
                expectedLanguageNameTranslatedInAppLanguage: "Spanish",
                expectedToolsAvailableCount: 2
            )
        ]
    )
    @MainActor func selectedLanguageIsReturnedWhenUserHasSelectedALanguage(argument: StoredLanguageArgument) async throws {

        let language: ToolFilterLanguageDomainModel = try await getUserToolFilterLanguage(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeLanguageId: argument.storedLanguageId
        )

        #expect(language.languageType == .language)
        #expect(language.filterId == argument.storedLanguageId)
        #expect(language.languageNamePair.nameInOwnLanguage == argument.expectedLanguageName)
        #expect(language.languageNamePair.nameInAppLanguage == argument.expectedLanguageNameTranslatedInAppLanguage)
        #expect(language.numberOfToolsAvailable == argument.expectedToolsAvailableCount)
        #expect(language.toolsAvailable == "\(englishToolsAvailableText) \(argument.expectedToolsAvailableCount)")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a tools filter language that no longer exists.
        When: The user's tools filter language is requested.
        Then: I expect to see the any language.
        """
    )
    @MainActor func anyLanguageIsReturnedWhenTheSelectedLanguageNoLongerExists() async throws {

        let language: ToolFilterLanguageDomainModel = try await getUserToolFilterLanguage(
            appLanguage: LanguageCodeDomainModel.english.value,
            storeLanguageId: TestUserFilterLanguageId.doesNotExist
        )

        #expect(language.languageType == .any)
        #expect(language.filterId == nil)
        #expect(language.languageNamePair.nameInAppLanguage == englishAnyLanguageName)
        #expect(language.numberOfToolsAvailable == 4)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing their selected tools filter language.
        When: My app language is set.
        Then: I expect to see the language name and number of tools available translated in my app language.
        """,
        arguments: [
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.english.value,
                expectedAnyLanguageName: "Any language",
                expectedFrenchNameTranslatedInAppLanguage: "French",
                expectedToolsAvailableText: "tools available"
            ),
            AppLanguageArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedAnyLanguageName: "Cualquier idioma",
                expectedFrenchNameTranslatedInAppLanguage: "Francés",
                expectedToolsAvailableText: "herramientas disponibles"
            )
        ]
    )
    @MainActor func languageIsTranslatedInMyAppLanguage(argument: AppLanguageArgument) async throws {

        let anyLanguage: ToolFilterLanguageDomainModel = try await getUserToolFilterLanguage(
            appLanguage: argument.appLanguage,
            storeLanguageId: nil
        )

        let frenchLanguage: ToolFilterLanguageDomainModel = try await getUserToolFilterLanguage(
            appLanguage: argument.appLanguage,
            storeLanguageId: TestUserFilterLanguageId.french
        )

        #expect(anyLanguage.languageNamePair.nameInAppLanguage == argument.expectedAnyLanguageName)
        #expect(anyLanguage.toolsAvailable == "\(argument.expectedToolsAvailableText) 4")

        #expect(frenchLanguage.languageNamePair.nameInOwnLanguage == "Français")
        #expect(frenchLanguage.languageNamePair.nameInAppLanguage == argument.expectedFrenchNameTranslatedInAppLanguage)
        #expect(frenchLanguage.toolsAvailable == "\(argument.expectedToolsAvailableText) 2")
    }
}

// MARK: - Test Helpers

extension GetUserToolFilterLanguageUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getUserToolFilterLanguage(appLanguage: AppLanguageDomainModel, storeLanguageId: String?) async throws -> ToolFilterLanguageDomainModel {

        let dependencies: TestDependencies = try getTestDependencies()

        if let storeLanguageId = storeLanguageId {
            try await dependencies.userToolFiltersRepository.storeUserLanguageFilter(languageId: storeLanguageId)
        }

        let useCase = GetUserToolFilterLanguageUseCase(
            userToolFiltersRepository: dependencies.userToolFiltersRepository,
            getToolFilterLanguage: getToolFilterLanguage(dependencies: dependencies)
        )

        var cancellables: Set<AnyCancellable> = Set()

        var languageRef: ToolFilterLanguageDomainModel?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink { (language: ToolFilterLanguageDomainModel) in

                    guard languageRef == nil else {
                        return
                    }

                    languageRef = language

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        return try #require(languageRef)
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
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            userToolFiltersRepository: testsDiContainer.feature.toolsFilter.dataLayer.getUserToolFiltersRepository()
        )
    }

    private func getToolFilterLanguage(dependencies: TestDependencies) -> GetToolFilterLanguage {

        return GetToolFilterLanguage(
            resourcesRepository: dependencies.resourcesRepository,
            languagesRepository: dependencies.languagesRepository,
            getTranslatedLanguageName: getTranslatedLanguageName(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: FakeStringWithLocaleCount()
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
            .english: Self.createLanguage(id: TestUserFilterLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestUserFilterLanguageId.french, code: .french),
            .spanish: Self.createLanguage(id: TestUserFilterLanguageId.spanish, code: .spanish)
        ]

        let tools: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.resourceType = ResourceType.tract.rawValue

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
            ToolFixture(id: "tool-1", languageCodes: [.english, .french, .spanish]),
            ToolFixture(id: "tool-2", languageCodes: [.english]),
            ToolFixture(id: "tool-3", languageCodes: [.english, .spanish]),
            ToolFixture(id: "tool-4", languageCodes: [.french])
        ]
    }
}
