//
//  GetDownloadableLanguagesListUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/27/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import SwiftData
import RepositorySync

struct GetDownloadableLanguagesListUseCaseTests {

    struct LanguageFixture {

        let id: String
        let languageCode: LanguageCodeDomainModel
        let numberOfToolsAvailable: Int
    }

    struct TestDependencies {

        let useCase: GetDownloadableLanguagesListUseCase
        let downloadedLanguagesRepository: DownloadedLanguagesRepository
    }

    struct TranslatedLanguageNamesTestArgument {

        let appLanguage: LanguageCodeDomainModel
        let expectedLanguageNames: [String: String]
    }

    struct ToolsAvailableTextTestArgument {

        let appLanguage: LanguageCodeDomainModel
        let expectedToolsAvailableText: [String: String]
    }

    struct SortedLanguagesTestArgument {

        let appLanguage: LanguageCodeDomainModel
        let expectedSortedLanguageIds: [String]
    }

    private static let czechLanguageId: String = "1"
    private static let englishLanguageId: String = "2"
    private static let spanishLanguageId: String = "3"
    private static let frenchLanguageId: String = "4"
    private static let russianLanguageId: String = "5"

    private static let toolsAvailableFormatInEnglish: String = "%d tools available"
    private static let toolsAvailableFormatInSpanish: String = "%d herramientas disponibles"

    private static let languageFixtures: [LanguageFixture] = [
        LanguageFixture(id: czechLanguageId, languageCode: .czech, numberOfToolsAvailable: 0),
        LanguageFixture(id: englishLanguageId, languageCode: .english, numberOfToolsAvailable: 3),
        LanguageFixture(id: spanishLanguageId, languageCode: .spanish, numberOfToolsAvailable: 2),
        LanguageFixture(id: frenchLanguageId, languageCode: .french, numberOfToolsAvailable: 1),
        LanguageFixture(id: russianLanguageId, languageCode: .russian, numberOfToolsAvailable: 1)
    ]

    private static let additionalLocalizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
        LanguageCodeDomainModel.english.value: [
            LocalizableStringKeys.toolsFilterToolsAvailable.key: toolsAvailableFormatInEnglish
        ],
        LanguageCodeDomainModel.spanish.value: [
            LocalizableStringKeys.toolsFilterToolsAvailable.key: toolsAvailableFormatInSpanish
        ]
    ]

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: A language has no tools available in it.
        Then: That language should not be listed as downloadable.
        """
    )
    @MainActor func onlyLanguagesWithAtLeastOneAvailableToolAreListed() async throws {

        let dependencies: TestDependencies = try await getTestDependencies()

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let expectedLanguageIds: Set<String> = [
            Self.englishLanguageId,
            Self.spanishLanguageId,
            Self.frenchLanguageId,
            Self.russianLanguageId
        ]

        #expect(Set(downloadableLanguages.map { $0.languageId }) == expectedLanguageIds)
        #expect(downloadableLanguages.contains(where: { $0.languageId == Self.czechLanguageId }) == false)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: The list is requested for the current app language.
        Then: Every language name should also be translated in its own language.
        """
    )
    @MainActor func languageNamesAreTranslatedInTheirOwnLanguage() async throws {

        let dependencies: TestDependencies = try await getTestDependencies()

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let expectedLanguageNames: [String: String] = [
            Self.englishLanguageId: "English",
            Self.spanishLanguageId: "Español",
            Self.frenchLanguageId: "Français",
            Self.russianLanguageId: "Русский"
        ]

        #expect(downloadableLanguages.isEmpty == false)

        for listItem in downloadableLanguages {

            #expect(listItem.languageNamePair.nameInOwnLanguage == expectedLanguageNames[listItem.languageId])
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: The list is requested for the current app language.
        Then: Every language name should be translated in the current app language.
        """,
        arguments: [
            TranslatedLanguageNamesTestArgument(
                appLanguage: .english,
                expectedLanguageNames: [
                    Self.englishLanguageId: "English",
                    Self.spanishLanguageId: "Spanish",
                    Self.frenchLanguageId: "French",
                    Self.russianLanguageId: "Russian"
                ]
            ),
            TranslatedLanguageNamesTestArgument(
                appLanguage: .spanish,
                expectedLanguageNames: [
                    Self.englishLanguageId: "Inglés",
                    Self.spanishLanguageId: "Español",
                    Self.frenchLanguageId: "Francés",
                    Self.russianLanguageId: "Ruso"
                ]
            )
        ]
    )
    @MainActor func languageNamesAreTranslatedInTheCurrentAppLanguage(argument: TranslatedLanguageNamesTestArgument) async throws {

        let dependencies: TestDependencies = try await getTestDependencies()

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: argument.appLanguage.value
        )

        #expect(downloadableLanguages.isEmpty == false)

        for listItem in downloadableLanguages {

            #expect(listItem.languageNamePair.nameInAppLanguage == argument.expectedLanguageNames[listItem.languageId])
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: The list is requested for the current app language.
        Then: Every language should display the number of tools available in it translated in the current app language.
        """,
        arguments: [
            ToolsAvailableTextTestArgument(
                appLanguage: .english,
                expectedToolsAvailableText: [
                    Self.englishLanguageId: Self.toolsAvailableFormatInEnglish + " 3",
                    Self.spanishLanguageId: Self.toolsAvailableFormatInEnglish + " 2",
                    Self.frenchLanguageId: Self.toolsAvailableFormatInEnglish + " 1",
                    Self.russianLanguageId: Self.toolsAvailableFormatInEnglish + " 1"
                ]
            ),
            ToolsAvailableTextTestArgument(
                appLanguage: .spanish,
                expectedToolsAvailableText: [
                    Self.englishLanguageId: Self.toolsAvailableFormatInSpanish + " 3",
                    Self.spanishLanguageId: Self.toolsAvailableFormatInSpanish + " 2",
                    Self.frenchLanguageId: Self.toolsAvailableFormatInSpanish + " 1",
                    Self.russianLanguageId: Self.toolsAvailableFormatInSpanish + " 1"
                ]
            )
        ]
    )
    @MainActor func numberOfAvailableToolsIsTranslatedInTheCurrentAppLanguage(argument: ToolsAvailableTextTestArgument) async throws {

        let dependencies: TestDependencies = try await getTestDependencies()

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: argument.appLanguage.value
        )

        #expect(downloadableLanguages.isEmpty == false)

        for listItem in downloadableLanguages {

            #expect(listItem.toolsAvailableText == argument.expectedToolsAvailableText[listItem.languageId])
        }
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: A language download completed, a language download did not complete, and a language was never downloaded.
        Then: Only the language whose download completed should be marked as downloaded.
        """
    )
    @MainActor func onlyLanguagesWithACompletedDownloadAreMarkedAsDownloaded() async throws {

        let dependencies: TestDependencies = try await getTestDependencies(
            completedDownloadLanguageIds: [Self.spanishLanguageId],
            incompleteDownloadLanguageIds: [Self.frenchLanguageId]
        )

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let spanish: DownloadableLanguageListItemDomainModel = try #require(downloadableLanguages.first(where: { $0.languageId == Self.spanishLanguageId }))
        let french: DownloadableLanguageListItemDomainModel = try #require(downloadableLanguages.first(where: { $0.languageId == Self.frenchLanguageId }))
        let english: DownloadableLanguageListItemDomainModel = try #require(downloadableLanguages.first(where: { $0.languageId == Self.englishLanguageId }))

        #expect(spanish.isDownloaded == true)
        #expect(french.downloadStatus == .notDownloaded)
        #expect(english.downloadStatus == .notDownloaded)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: A language was already downloaded before the list was viewed.
        Then: The downloaded language should be listed first, followed by the remaining languages sorted by their name translated in the current app language.
        """,
        arguments: [
            SortedLanguagesTestArgument(
                appLanguage: .english,
                expectedSortedLanguageIds: [Self.spanishLanguageId, Self.englishLanguageId, Self.frenchLanguageId, Self.russianLanguageId]
            ),
            SortedLanguagesTestArgument(
                appLanguage: .spanish,
                expectedSortedLanguageIds: [Self.spanishLanguageId, Self.frenchLanguageId, Self.englishLanguageId, Self.russianLanguageId]
            )
        ]
    )
    @MainActor func alreadyDownloadedLanguagesAreSortedFirst(argument: SortedLanguagesTestArgument) async throws {

        let dependencies: TestDependencies = try await getTestDependencies(
            completedDownloadLanguageIds: [Self.spanishLanguageId]
        )

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: argument.appLanguage.value
        )

        #expect(downloadableLanguages.map { $0.languageId } == argument.expectedSortedLanguageIds)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the downloadable languages list.
        When: A language is downloaded while the list is being viewed.
        Then: The language should be marked as downloaded but should keep its sorted position in the list.
        """
    )
    @MainActor func languagesDownloadedWhileViewingTheListKeepTheirSortedPosition() async throws {

        let dependencies: TestDependencies = try await getTestDependencies()

        _ = try await dependencies.downloadedLanguagesRepository.storeDownloadedLanguage(
            languageId: Self.russianLanguageId,
            downloadComplete: true
        )

        let downloadableLanguages: [DownloadableLanguageListItemDomainModel] = await getDownloadableLanguagesList(
            useCase: dependencies.useCase,
            appLanguage: LanguageCodeDomainModel.english.value
        )

        let russian: DownloadableLanguageListItemDomainModel = try #require(downloadableLanguages.first(where: { $0.languageId == Self.russianLanguageId }))

        let expectedSortedLanguageIds: [String] = [
            Self.englishLanguageId,
            Self.frenchLanguageId,
            Self.russianLanguageId,
            Self.spanishLanguageId
        ]

        #expect(russian.isDownloaded == true)
        #expect(downloadableLanguages.map { $0.languageId } == expectedSortedLanguageIds)
    }
}

// MARK: - Test Helpers

extension GetDownloadableLanguagesListUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getDownloadableLanguagesList(
        useCase: GetDownloadableLanguagesListUseCase,
        appLanguage: AppLanguageDomainModel
    ) async -> [DownloadableLanguageListItemDomainModel] {

        var cancellables: Set<AnyCancellable> = Set()

        var downloadableLanguagesRef: [DownloadableLanguageListItemDomainModel] = Array()
        var didReceiveDownloadableLanguages: Bool = false

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(appLanguage: appLanguage)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (downloadableLanguages: [DownloadableLanguageListItemDomainModel]) in

                    guard !downloadableLanguages.isEmpty && !didReceiveDownloadableLanguages else {
                        return
                    }

                    didReceiveDownloadableLanguages = true

                    downloadableLanguagesRef = downloadableLanguages

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return downloadableLanguagesRef
    }

    @available(iOS 17.4, *)
    private func getTestDependencies(
        completedDownloadLanguageIds: [String] = [],
        incompleteDownloadLanguageIds: [String] = []
    ) async throws -> TestDependencies {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: getSwiftDatabaseObjects())

        try context.saveIfHasChanges()

        let testsDiContainer = TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )

        let downloadedLanguagesRepository: DownloadedLanguagesRepository = testsDiContainer.feature.appLanguage.dataLayer.getDownloadedLanguagesRepository()

        for languageId in completedDownloadLanguageIds {

            _ = try await downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: true)
        }

        for languageId in incompleteDownloadLanguageIds {

            _ = try await downloadedLanguagesRepository.storeDownloadedLanguage(languageId: languageId, downloadComplete: false)
        }

        let useCase = GetDownloadableLanguagesListUseCase(
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            downloadedLanguagesRepository: downloadedLanguagesRepository,
            getTranslatedLanguageName: getTranslatedLanguageName(),
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: FakeStringWithLocaleCount()
        )

        return TestDependencies(
            useCase: useCase,
            downloadedLanguagesRepository: downloadedLanguagesRepository
        )
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        var languages: [SwiftLanguage] = Array()
        var tools: [SwiftResource] = Array()

        for fixture in Self.languageFixtures {

            let language = SwiftLanguage()
            language.id = fixture.id
            language.code = fixture.languageCode.rawValue
            language.name = fixture.languageCode.rawValue + " Name"

            languages.append(language)

            for toolIndex in 0 ..< fixture.numberOfToolsAvailable {

                let tool = SwiftResource()
                tool.id = fixture.id + "-tool-" + String(toolIndex)
                tool.resourceType = ResourceType.tract.rawValue
                tool.addLanguage(language: language)

                tools.append(tool)
            }
        }

        return languages + tools
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: Self.additionalLocalizableStrings
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
}
