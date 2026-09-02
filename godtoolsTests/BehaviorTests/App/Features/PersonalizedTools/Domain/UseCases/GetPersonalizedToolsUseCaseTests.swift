//
//  GetPersonalizedToolsUseCaseTests.swift
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

private enum TestPersonalizedToolsLanguageId {
    static let english: String = "0"
    static let french: String = "1"
}

private enum TestPersonalizedToolsId {
    static let defaultOrderEnglish: String = "default_order_en"
    static let defaultOrderFrench: String = "default_order_fr"
    static let rankedUnitedStatesEnglish: String = "ranked_us_en"
}

struct GetPersonalizedToolsUseCaseTests {

    struct ToolFixture {
        let id: String
        let resourceType: ResourceType
        let languageCodes: [LanguageCodeDomainModel]
    }

    struct TestDependencies {
        let resourcesRepository: ResourcesRepository
        let languagesRepository: LanguagesRepository
        let personalizedToolsRepository: PersonalizedToolsRepository
        let getToolsListItems: GetToolsListItems
    }

    struct UnavailableArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedTitle: String
        let expectedMessage: String
    }

    private let englishUnavailableTitle: String = "Personalization unavailable"
    private let englishUnavailableMessage: String = "We could not personalize your tools."
    private let germanUnavailableTitle: String = "Personalisierung nicht verfügbar"
    private let germanUnavailableMessage: String = "Wir konnten deine Tools nicht personalisieren."
    private let spanishUnavailableTitle: String = "Personalización no disponible"
    private let spanishUnavailableMessage: String = "No pudimos personalizar tus herramientas."

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country.
        When: Personalized tools are requested.
        Then: I expect to see the tools personalized for my country and language.
        """
    )
    @MainActor func personalizedToolsForMySelectedCountryAreReturned() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: "us"),
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        #expect(personalizedTools.tools.map({ $0.id }).sorted() == ["tool-1", "tool-3"])
        #expect(personalizedTools.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a country.
        When: Personalized tools are requested.
        Then: I expect to see the default order tools for my app language.
        """
    )
    @MainActor func defaultOrderToolsAreReturnedWhenNoCountryIsSelected() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        #expect(personalizedTools.tools.map({ $0.id }).sorted() == ["tool-1", "tool-2"])
        #expect(personalizedTools.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: The personalized tools include a lesson.
        When: Personalized tools are requested.
        Then: I expect to see only tools and not the lesson.
        """
    )
    @MainActor func lessonsAreNotIncludedInPersonalizedTools() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        #expect(!personalizedTools.tools.map({ $0.id }).contains("lesson-1"))
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a tools filter language.
        When: Personalized tools are requested.
        Then: I expect to see the tools personalized for the filter language rather than my app language.
        """
    )
    @MainActor func personalizedToolsForTheSelectedFilterLanguageAreReturned() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterToolsByLanguage: ToolFilterLanguageDomainModel.createLanguage(
                id: TestPersonalizedToolsLanguageId.french,
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: ""),
                toolsAvailable: "",
                numberOfToolsAvailable: 0
            )
        )

        #expect(personalizedTools.tools.map({ $0.id }) == ["tool-4"])
        #expect(personalizedTools.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: There are no personalized tools.
        When: Personalized tools are requested.
        Then: I expect to see the personalization unavailable strings translated in my app language.
        """,
        arguments: [
            UnavailableArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedTitle: "Personalización no disponible",
                expectedMessage: "No pudimos personalizar tus herramientas."
            ),
            UnavailableArgument(
                appLanguage: LanguageCodeDomainModel.german.value,
                expectedTitle: "Personalisierung nicht verfügbar",
                expectedMessage: "Wir konnten deine Tools nicht personalisieren."
            )
        ]
    )
    @MainActor func personalizationUnavailableIsShownWhenThereAreNoTools(argument: UnavailableArgument) async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: argument.appLanguage,
            country: nil,
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        let unavailableStrings: PersonalizedToolsUnavailableDomainModel = try #require(personalizedTools.unavailableStrings)

        #expect(personalizedTools.tools.isEmpty)
        #expect(unavailableStrings.title == argument.expectedTitle)
        #expect(unavailableStrings.message == argument.expectedMessage)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country and there are no personalized tools.
        When: Personalized tools are requested.
        Then: I expect to see no tools and the personalization unavailable strings.
        """
    )
    @MainActor func personalizationUnavailableIsShownWhenACountryIsSelectedAndThereAreNoTools() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: "ca"),
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        #expect(personalizedTools.tools.isEmpty)
        #expect(personalizedTools.unavailableStrings != nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country with an empty region code.
        When: Personalized tools are requested.
        Then: I expect to see the default order tools for my app language as though no country was selected.
        """
    )
    @MainActor func countryWithAnEmptyRegionCodeIsTreatedAsNoCountrySelected() async throws {

        let personalizedTools: PersonalizedToolsDomainModel = try await getPersonalizedTools(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: ""),
            filterToolsByLanguage: ToolFilterLanguageDomainModel.emptyValue
        )

        #expect(personalizedTools.tools.map({ $0.id }).sorted() == ["tool-1", "tool-2"])
        #expect(personalizedTools.unavailableStrings == nil)
    }
}

// MARK: - Test Helpers

extension GetPersonalizedToolsUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getPersonalizedTools(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterToolsByLanguage: ToolFilterLanguageDomainModel) async throws -> PersonalizedToolsDomainModel {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = GetPersonalizedToolsUseCase(
            resourcesRepository: dependencies.resourcesRepository,
            personalizedToolsRepository: dependencies.personalizedToolsRepository,
            getLanguageElseAppLanguage: GetLanguageElseAppLanguage(languagesRepository: dependencies.languagesRepository),
            getToolsListItems: dependencies.getToolsListItems,
            localizationServices: getLocalizationServices()
        )

        var cancellables: Set<AnyCancellable> = Set()

        var personalizedToolsRef: PersonalizedToolsDomainModel?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    country: country,
                    filterToolsByLanguage: filterToolsByLanguage
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (personalizedTools: PersonalizedToolsDomainModel) in

                    guard personalizedToolsRef == nil else {
                        return
                    }

                    personalizedToolsRef = personalizedTools

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(personalizedToolsRef)
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

        let resourcesRepository: ResourcesRepository = testsDiContainer.core.dataLayer.getResourcesRepository()

        let api = FakePersonalizedToolsApi(resourceIdsByPersonalizedToolsId: resourceIdsByPersonalizedToolsId)
        
        let cache = PersonalizedToolsCache(
            persistence: SwiftRepositorySyncPersistence(
                database: swiftDatabase,
                mapping: SwiftPersonalizedToolsMapping()
            )
        )
        
        let personalizedToolsRepository = PersonalizedToolsRepository(
            cache: cache,
            resourcesRepository: resourcesRepository,
            sync: PersonalizedToolsSync(api: api, cache: cache, syncInvalidatorPersistence: FakeSyncInvalidatorPersistence())
        )

        return TestDependencies(
            resourcesRepository: resourcesRepository,
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            personalizedToolsRepository: personalizedToolsRepository,
            getToolsListItems: testsDiContainer.core.domainLayer.supporting.getToolsListItems()
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices(localizableStrings: [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.toolsPersonalizationUnavailableTitle.key: englishUnavailableTitle,
                LocalizableStringKeys.toolsPersonalizationUnavailableMessage.key: englishUnavailableMessage
            ],
            LanguageCodeDomainModel.german.value: [
                LocalizableStringKeys.toolsPersonalizationUnavailableTitle.key: germanUnavailableTitle,
                LocalizableStringKeys.toolsPersonalizationUnavailableMessage.key: germanUnavailableMessage
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.toolsPersonalizationUnavailableTitle.key: spanishUnavailableTitle,
                LocalizableStringKeys.toolsPersonalizationUnavailableMessage.key: spanishUnavailableMessage
            ]
        ])
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .english: Self.createLanguage(id: TestPersonalizedToolsLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestPersonalizedToolsLanguageId.french, code: .french)
        ]

        let resources: [SwiftResource] = allTools.map { (fixture: ToolFixture) in

            let resource = SwiftResource()
            resource.id = fixture.id
            resource.resourceType = fixture.resourceType.rawValue

            for languageCode in fixture.languageCodes {

                guard let language = languagesByCode[languageCode] else {
                    continue
                }

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

        return Array(languagesByCode.values) + resources + personalizedTools
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
            TestPersonalizedToolsId.defaultOrderEnglish: ["tool-1", "tool-2", "lesson-1"],
            TestPersonalizedToolsId.defaultOrderFrench: ["tool-4"],
            TestPersonalizedToolsId.rankedUnitedStatesEnglish: ["tool-3", "tool-1"]
        ]
    }

    private var allTools: [ToolFixture] {

        return [
            ToolFixture(id: "tool-1", resourceType: .tract, languageCodes: [.english, .french]),
            ToolFixture(id: "tool-2", resourceType: .tract, languageCodes: [.english]),
            ToolFixture(id: "tool-3", resourceType: .article, languageCodes: [.english]),
            ToolFixture(id: "tool-4", resourceType: .tract, languageCodes: [.french]),
            ToolFixture(id: "lesson-1", resourceType: .lesson, languageCodes: [.english])
        ]
    }
}
