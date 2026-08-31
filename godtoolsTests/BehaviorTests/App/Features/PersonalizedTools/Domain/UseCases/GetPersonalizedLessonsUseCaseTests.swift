//
//  GetPersonalizedLessonsUseCaseTests.swift
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

private enum TestPersonalizedLessonsLanguageId {
    static let english: String = "0"
    static let french: String = "1"
}

private enum TestPersonalizedLessonsId {
    static let defaultOrderEnglish: String = "en"
    static let defaultOrderFrench: String = "fr"
    static let unitedStatesEnglish: String = "us_en"
}

struct GetPersonalizedLessonsUseCaseTests {

    struct ResourceFixture {
        let id: String
        let resourceType: ResourceType
        let languageCodes: [LanguageCodeDomainModel]
    }

    struct TestDependencies {
        let resourcesRepository: ResourcesRepository
        let languagesRepository: LanguagesRepository
        let personalizedToolsRepository: PersonalizedToolsRepository
        let userLessonProgressRepository: UserLessonProgressRepository
        let getLessonsListItems: GetLessonsListItems
    }

    struct UnavailableArgument {
        let appLanguage: AppLanguageDomainModel
        let expectedTitle: String
        let expectedMessage: String
    }

    private let englishUnavailableTitle: String = "Personalization unavailable"
    private let englishUnavailableMessage: String = "We could not personalize your lessons."
    private let germanUnavailableTitle: String = "Personalisierung nicht verfügbar"
    private let germanUnavailableMessage: String = "Wir konnten deine Lektionen nicht personalisieren."
    private let spanishUnavailableTitle: String = "Personalización no disponible"
    private let spanishUnavailableMessage: String = "No pudimos personalizar tus lecciones."

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country.
        When: Personalized lessons are requested.
        Then: I expect to see the lessons personalized for my country and language.
        """
    )
    @MainActor func personalizedLessonsForMySelectedCountryAreReturned() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: "us"),
            filterLessonsByLanguage: nil
        )

        #expect(personalizedLessons.lessons.map({ $0.dataModelId }).sorted() == ["lesson-1", "lesson-3"])
        #expect(personalizedLessons.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has not selected a country.
        When: Personalized lessons are requested.
        Then: I expect to see the default order lessons for my app language.
        """
    )
    @MainActor func defaultOrderLessonsAreReturnedWhenNoCountryIsSelected() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterLessonsByLanguage: nil
        )

        #expect(personalizedLessons.lessons.map({ $0.dataModelId }).sorted() == ["lesson-1", "lesson-2"])
        #expect(personalizedLessons.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: The personalized resources include tools.
        When: Personalized lessons are requested.
        Then: I expect to see only lessons and not the tools.
        """
    )
    @MainActor func toolsAreNotIncludedInPersonalizedLessons() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterLessonsByLanguage: nil
        )

        #expect(!personalizedLessons.lessons.map({ $0.dataModelId }).contains("tool-1"))
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a lessons filter language.
        When: Personalized lessons are requested.
        Then: I expect to see the lessons personalized for the filter language rather than my app language.
        """
    )
    @MainActor func personalizedLessonsForTheSelectedFilterLanguageAreReturned() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: nil,
            filterLessonsByLanguage: LessonFilterLanguageDomainModel(
                languageId: TestPersonalizedLessonsLanguageId.french,
                languageNameTranslatedInLanguage: "",
                languageNameTranslatedInAppLanguage: "",
                lessonsAvailableText: "",
                lessonsAvailableCount: 0
            )
        )

        #expect(personalizedLessons.lessons.map({ $0.dataModelId }) == ["lesson-4"])
        #expect(personalizedLessons.unavailableStrings == nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: There are no personalized lessons.
        When: Personalized lessons are requested.
        Then: I expect to see the personalization unavailable strings translated in my app language.
        """,
        arguments: [
            UnavailableArgument(
                appLanguage: LanguageCodeDomainModel.spanish.value,
                expectedTitle: "Personalización no disponible",
                expectedMessage: "No pudimos personalizar tus lecciones."
            ),
            UnavailableArgument(
                appLanguage: LanguageCodeDomainModel.german.value,
                expectedTitle: "Personalisierung nicht verfügbar",
                expectedMessage: "Wir konnten deine Lektionen nicht personalisieren."
            )
        ]
    )
    @MainActor func personalizationUnavailableIsShownWhenThereAreNoLessons(argument: UnavailableArgument) async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: argument.appLanguage,
            country: nil,
            filterLessonsByLanguage: nil
        )

        let unavailableStrings: PersonalizedLessonsUnavailableDomainModel = try #require(personalizedLessons.unavailableStrings)

        #expect(personalizedLessons.lessons.isEmpty)
        #expect(unavailableStrings.title == argument.expectedTitle)
        #expect(unavailableStrings.message == argument.expectedMessage)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country and there are no personalized lessons.
        When: Personalized lessons are requested.
        Then: I expect to see no lessons and the personalization unavailable strings.
        """
    )
    @MainActor func personalizationUnavailableIsShownWhenACountryIsSelectedAndThereAreNoLessons() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: "ca"),
            filterLessonsByLanguage: nil
        )

        #expect(personalizedLessons.lessons.isEmpty)
        #expect(personalizedLessons.unavailableStrings != nil)
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User has selected a country with an empty region code.
        When: Personalized lessons are requested.
        Then: I expect to see the default order lessons for my app language as though no country was selected.
        """
    )
    @MainActor func countryWithAnEmptyRegionCodeIsTreatedAsNoCountrySelected() async throws {

        let personalizedLessons: PersonalizedLessonsDomainModel = try await getPersonalizedLessons(
            appLanguage: LanguageCodeDomainModel.english.value,
            country: LocalizationSettingsCountryDomainModel(isoRegionCode: ""),
            filterLessonsByLanguage: nil
        )

        #expect(personalizedLessons.lessons.map({ $0.dataModelId }).sorted() == ["lesson-1", "lesson-2"])
        #expect(personalizedLessons.unavailableStrings == nil)
    }
}

// MARK: - Test Helpers

extension GetPersonalizedLessonsUseCaseTests {

    @available(iOS 17.4, *)
    @MainActor private func getPersonalizedLessons(appLanguage: AppLanguageDomainModel, country: LocalizationSettingsCountryDomainModel?, filterLessonsByLanguage: LessonFilterLanguageDomainModel?) async throws -> PersonalizedLessonsDomainModel {

        let dependencies: TestDependencies = try getTestDependencies()

        let useCase = GetPersonalizedLessonsUseCase(
            resourcesRepository: dependencies.resourcesRepository,
            personalizedToolsRepository: dependencies.personalizedToolsRepository,
            getLanguageElseAppLanguage: GetLanguageElseAppLanguage(languagesRepository: dependencies.languagesRepository),
            lessonProgressRepository: dependencies.userLessonProgressRepository,
            getLessonsListItems: dependencies.getLessonsListItems,
            localizationServices: getLocalizationServices()
        )

        var cancellables: Set<AnyCancellable> = Set()

        var personalizedLessonsRef: PersonalizedLessonsDomainModel?

        await withCheckedContinuation { continuation in

            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }

            useCase
                .execute(
                    appLanguage: appLanguage,
                    country: country,
                    filterLessonsByLanguage: filterLessonsByLanguage
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in

                }, receiveValue: { (personalizedLessons: PersonalizedLessonsDomainModel) in

                    guard personalizedLessonsRef == nil else {
                        return
                    }

                    personalizedLessonsRef = personalizedLessons

                    timeoutTask.cancel()
                    continuation.resume(returning: ())
                })
                .store(in: &cancellables)
        }

        return try #require(personalizedLessonsRef)
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
            api: api,
            cache: cache,
            resourcesRepository: resourcesRepository
        )

        return TestDependencies(
            resourcesRepository: resourcesRepository,
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            personalizedToolsRepository: personalizedToolsRepository,
            userLessonProgressRepository: testsDiContainer.core.dataLayer.getUserLessonProgressRepository(),
            getLessonsListItems: testsDiContainer.core.domainLayer.supporting.getLessonsListItems()
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        return FakeLocalizationServices(localizableStrings: [
            LanguageCodeDomainModel.english.value: [
                LocalizableStringKeys.lessonsPersonalizationUnavailableTitle.key: englishUnavailableTitle,
                LocalizableStringKeys.lessonsPersonalizationUnavailableMessage.key: englishUnavailableMessage
            ],
            LanguageCodeDomainModel.german.value: [
                LocalizableStringKeys.lessonsPersonalizationUnavailableTitle.key: germanUnavailableTitle,
                LocalizableStringKeys.lessonsPersonalizationUnavailableMessage.key: germanUnavailableMessage
            ],
            LanguageCodeDomainModel.spanish.value: [
                LocalizableStringKeys.lessonsPersonalizationUnavailableTitle.key: spanishUnavailableTitle,
                LocalizableStringKeys.lessonsPersonalizationUnavailableMessage.key: spanishUnavailableMessage
            ]
        ])
    }

    @available(iOS 17.4, *)
    private func getSwiftDatabaseObjects() -> [any PersistentModel] {

        let languagesByCode: [LanguageCodeDomainModel: SwiftLanguage] = [
            .english: Self.createLanguage(id: TestPersonalizedLessonsLanguageId.english, code: .english),
            .french: Self.createLanguage(id: TestPersonalizedLessonsLanguageId.french, code: .french)
        ]

        let resources: [SwiftResource] = allResources.map { (fixture: ResourceFixture) in

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
            TestPersonalizedLessonsId.defaultOrderEnglish: ["lesson-1", "lesson-2", "tool-1"],
            TestPersonalizedLessonsId.defaultOrderFrench: ["lesson-4"],
            TestPersonalizedLessonsId.unitedStatesEnglish: ["lesson-3", "lesson-1"]
        ]
    }

    private var allResources: [ResourceFixture] {

        return [
            ResourceFixture(id: "lesson-1", resourceType: .lesson, languageCodes: [.english, .french]),
            ResourceFixture(id: "lesson-2", resourceType: .lesson, languageCodes: [.english]),
            ResourceFixture(id: "lesson-3", resourceType: .lesson, languageCodes: [.english]),
            ResourceFixture(id: "lesson-4", resourceType: .lesson, languageCodes: [.french]),
            ResourceFixture(id: "tool-1", resourceType: .tract, languageCodes: [.english])
        ]
    }
}
