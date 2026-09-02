//
//  GetAppLanguagesListUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import RepositorySync

struct GetAppLanguagesListUseCaseTests {

    struct TranslatedLanguageNamesTestArgument {

        let appLanguage: LanguageCodeDomainModel
        let expectedLanguageNames: [AppLanguageDomainModel: String]
    }

    struct SortedAppLanguagesTestArgument {

        let appLanguage: LanguageCodeDomainModel
        let expectedSortedLanguages: [AppLanguageDomainModel]
    }

    private static let appLanguages: [AppLanguageCodable] = [
        AppLanguageCodable(languageCode: "cs", languageDirection: .leftToRight, languageScriptCode: nil),
        AppLanguageCodable(languageCode: "en", languageDirection: .leftToRight, languageScriptCode: nil),
        AppLanguageCodable(languageCode: "es", languageDirection: .leftToRight, languageScriptCode: nil),
        AppLanguageCodable(languageCode: "fr", languageDirection: .leftToRight, languageScriptCode: nil),
        AppLanguageCodable(languageCode: "ru", languageDirection: .leftToRight, languageScriptCode: nil),
        AppLanguageCodable(languageCode: "zh", languageDirection: .leftToRight, languageScriptCode: "Hans")
    ]

    private static let additionalLanguageNames: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
        LanguageCodeDomainModel.english.value: [
            LanguageCodeDomainModel.chineseSimplified.rawValue: "Chinese (Simplified)"
        ],
        LanguageCodeDomainModel.spanish.value: [
            LanguageCodeDomainModel.chineseSimplified.rawValue: "Chino simplificado"
        ],
        LanguageCodeDomainModel.chineseSimplified.value: [
            LanguageCodeDomainModel.chineseSimplified.rawValue: "简体中文"
        ]
    ]

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the app languages list.
        When: The app languages list is requested.
        Then: The list should contain an item for every available app language.
        """
    )
    func appLanguagesListContainsAnItemForEveryAvailableAppLanguage() async throws {

        let useCase = try await getUseCase(appLanguages: Self.appLanguages)

        let appLanguagesList: [AppLanguageListItemDomainModel] = try await useCase.execute(appLanguage: LanguageCodeDomainModel.english.value)

        let expectedLanguages: Set<AppLanguageDomainModel> = ["cs", "en", "es", "fr", "ru", "zh-Hans"]

        #expect(appLanguagesList.count == Self.appLanguages.count)
        #expect(Set(appLanguagesList.map { $0.language }) == expectedLanguages)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the app languages list.
        When: The app languages list is requested.
        Then: Every language name should also be translated in its own language.
        """
    )
    func languageNamesAreTranslatedInTheirOwnLanguage() async throws {

        let useCase = try await getUseCase(appLanguages: Self.appLanguages)

        let appLanguagesList: [AppLanguageListItemDomainModel] = try await useCase.execute(appLanguage: LanguageCodeDomainModel.english.value)

        let expectedLanguageNames: [AppLanguageDomainModel: String] = [
            "cs": "čeština",
            "en": "English",
            "es": "Español",
            "fr": "Français",
            "ru": "Русский",
            "zh-Hans": "简体中文"
        ]

        for listItem in appLanguagesList {

            #expect(listItem.languageNamePair.nameInOwnLanguage == expectedLanguageNames[listItem.language])
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the app languages list.
        When: The app languages list is requested for the current app language.
        Then: Every language name should be translated in the current app language.
        """,
        arguments: [
            TranslatedLanguageNamesTestArgument(
                appLanguage: .english,
                expectedLanguageNames: [
                    "cs": "Czech",
                    "en": "English",
                    "es": "Spanish",
                    "fr": "French",
                    "ru": "Russian",
                    "zh-Hans": "Chinese (Simplified)"
                ]
            ),
            TranslatedLanguageNamesTestArgument(
                appLanguage: .spanish,
                expectedLanguageNames: [
                    "cs": "Checo",
                    "en": "Inglés",
                    "es": "Español",
                    "fr": "Francés",
                    "ru": "Ruso",
                    "zh-Hans": "Chino simplificado"
                ]
            )
        ]
    )
    func languageNamesAreTranslatedInTheCurrentAppLanguage(argument: TranslatedLanguageNamesTestArgument) async throws {

        let useCase = try await getUseCase(appLanguages: Self.appLanguages)

        let appLanguagesList: [AppLanguageListItemDomainModel] = try await useCase.execute(appLanguage: argument.appLanguage.value)

        for listItem in appLanguagesList {

            #expect(listItem.languageNamePair.nameInAppLanguage == argument.expectedLanguageNames[listItem.language])
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the app languages list.
        When: The app languages list is requested for the current app language.
        Then: The list should be sorted alphabetically by the language name translated in the current app language.
        """,
        arguments: [
            SortedAppLanguagesTestArgument(
                appLanguage: .english,
                expectedSortedLanguages: ["zh-Hans", "cs", "en", "fr", "ru", "es"]
            ),
            SortedAppLanguagesTestArgument(
                appLanguage: .spanish,
                expectedSortedLanguages: ["cs", "zh-Hans", "es", "fr", "en", "ru"]
            )
        ]
    )
    func appLanguagesListIsSortedByLanguageNameTranslatedInTheCurrentAppLanguage(argument: SortedAppLanguagesTestArgument) async throws {

        let useCase = try await getUseCase(appLanguages: Self.appLanguages)

        let appLanguagesList: [AppLanguageListItemDomainModel] = try await useCase.execute(appLanguage: argument.appLanguage.value)

        #expect(appLanguagesList.map { $0.language } == argument.expectedSortedLanguages)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the app languages list.
        When: There are no available app languages.
        Then: The list should be empty.
        """
    )
    func appLanguagesListIsEmptyWhenThereAreNoAvailableAppLanguages() async throws {

        let useCase = try await getUseCase(appLanguages: [])

        let appLanguagesList: [AppLanguageListItemDomainModel] = try await useCase.execute(appLanguage: LanguageCodeDomainModel.english.value)

        #expect(appLanguagesList.isEmpty)
    }
}

// MARK: - Test Helpers

extension GetAppLanguagesListUseCaseTests {

    @available(iOS 17.4, *)
    private func getUseCase(appLanguages: [AppLanguageCodable]) async throws -> GetAppLanguagesListUseCase {

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())
            )
        )

        let persistence: any Persistence<AppLanguageDataModel, AppLanguageCodable> = testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesPersistence()

        let appLanguagesSync = try await FakeAppLanguagesRepositorySync(
            persistence: persistence,
            appLanguages: appLanguages
        )
        
        try await appLanguagesSync.sync()

        let appLanguagesRepository = AppLanguagesRepository(
            api: AppLanguagesApi(),
            cache: AppLanguagesCache(persistence: persistence)
        )

        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(
                localizationServices: FakeLocalizationServices.createLanguageNamesLocalizationServices(addAdditionalLocalizableStrings: Self.additionalLanguageNames)
            ),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )

        return GetAppLanguagesListUseCase(
            appLanguagesRepository: appLanguagesRepository,
            getTranslatedLanguageName: getTranslatedLanguageName
        )
    }
}
