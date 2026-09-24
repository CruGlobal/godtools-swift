//
//  GetUserLessonFilterLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Foundation
import Combine
import SwiftData
import RepositorySync

struct GetUserLessonFilterLanguageUseCaseTests {

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: A lesson language filter hasn't been selected by the user.
        Then: The lesson language filter should default to the current app language when lessons exist in the current app language.
        """
    )
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsExistInAppLanguage() async throws {

        let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue

        let spanishLanguage = SwiftLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"

        let spanishLesson_0 = SwiftResource()
        spanishLesson_0.id = "es-lesson-0"
        spanishLesson_0.resourceType = ResourceType.lesson.rawValue
        spanishLesson_0.addLanguage(language: spanishLanguage)

        let swiftObjectsToAdd: [any PersistentModel] = [spanishLanguage, spanishLesson_0]

        let getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase = try getUserLessonFilterLanguageUseCase(addSwiftObjects: swiftObjectsToAdd)

        let userLessonFilterLanguage: LessonFilterLanguageDomainModel? = try await getUserLessonFilterLanguageUseCase
            .execute(appLanguage: appLanguageSpanish)
            .awaitFirstValue()

        let lessonLanguageFilter: LessonFilterLanguageDomainModel = try #require(userLessonFilterLanguage)

        #expect(lessonLanguageFilter.languageNamePair.nameInOwnLanguage == "Español")
        #expect(lessonLanguageFilter.languageNamePair.nameInAppLanguage == "Español")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: A lesson language filter hasn't been selected by the user.
        Then: The lesson language filter should default to the current app language even when lessons don't exist in the current app language.
        """
    )
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsDontExistInAppLanguage() async throws {

        let appLanguageFrench: AppLanguageDomainModel = LanguageCodeDomainModel.french.rawValue

        let spanishLanguage = SwiftLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"

        let frenchLanguage = SwiftLanguage()
        frenchLanguage.id = "1"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"

        let spanishLesson_0 = SwiftResource()
        spanishLesson_0.id = "es-lesson-0"
        spanishLesson_0.resourceType = ResourceType.lesson.rawValue
        spanishLesson_0.addLanguage(language: spanishLanguage)

        let frenchTract_0 = SwiftResource()
        frenchTract_0.id = "fr-lesson-0"
        frenchTract_0.resourceType = ResourceType.tract.rawValue
        frenchTract_0.addLanguage(language: frenchLanguage)

        let swiftObjectsToAdd: [any PersistentModel] = [spanishLanguage, frenchLanguage, spanishLesson_0, frenchTract_0]

        let getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase = try getUserLessonFilterLanguageUseCase(addSwiftObjects: swiftObjectsToAdd)

        let userLessonFilterLanguage: LessonFilterLanguageDomainModel? = try await getUserLessonFilterLanguageUseCase
            .execute(appLanguage: appLanguageFrench)
            .awaitFirstValue()

        let lessonLanguageFilter: LessonFilterLanguageDomainModel = try #require(userLessonFilterLanguage)

        #expect(lessonLanguageFilter.languageNamePair.nameInOwnLanguage == "Français")
        #expect(lessonLanguageFilter.languageNamePair.nameInAppLanguage == "Français")
    }

    @available(iOS 17.4, *)
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: The app language is french and the user has selected lesson language filter spanish.
        Then: The lesson language filter should be spanish.
        """
    )
    @MainActor func lessonsLanguageFilterIsTheSelectedLanguageFilterAndNotDefaultingAppLanguage() async throws {

        let appLanguageFrench: AppLanguageDomainModel = LanguageCodeDomainModel.french.rawValue

        let spanishLanguage = SwiftLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"

        let frenchLanguage = SwiftLanguage()
        frenchLanguage.id = "1"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"

        let swiftObjectsToAdd: [any PersistentModel] = [spanishLanguage, frenchLanguage]

        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(addSwiftObjects: swiftObjectsToAdd)

        let getUserLessonFilterLanguageUseCase: GetUserLessonFilterLanguageUseCase = getUserLessonFilterLanguageUseCase(testsDiContainer: testsDiContainer)

        let userToolFilterSettingsRepository: UserToolFilterSettingsRepository = testsDiContainer.core.dataLayer.getUserToolFilterSettingsRepository()

        let spanishLanguageId: String = spanishLanguage.id

        let lessonLanguageFilters: [LessonFilterLanguageDomainModel?] = try await getUserLessonFilterLanguageUseCase
            .execute(appLanguage: appLanguageFrench)
            .awaitValues(count: 2, whileObserving: {

                try await userToolFilterSettingsRepository.storeSettingValue(
                    settingType: .lessonsLanguageFilter,
                    value: spanishLanguageId
                )
            })

        let originalLessonLanguageFilter: LessonFilterLanguageDomainModel = try #require(lessonLanguageFilters[0])
        let selectedLessonLanguageFilter: LessonFilterLanguageDomainModel = try #require(lessonLanguageFilters[1])

        #expect(originalLessonLanguageFilter.languageNamePair.nameInOwnLanguage == "Français")
        #expect(originalLessonLanguageFilter.languageNamePair.nameInAppLanguage == "Français")

        #expect(selectedLessonLanguageFilter.languageNamePair.nameInOwnLanguage == "Español")
        #expect(selectedLessonLanguageFilter.languageNamePair.nameInAppLanguage == "Espagnol")
    }
}

extension GetUserLessonFilterLanguageUseCaseTests {

    @available(iOS 17.4, *)
    private func getTestsDiContainer(addSwiftObjects: [any PersistentModel]) throws -> TestsDiContainer {

        let swiftDatabase = SwiftDatabase(container: try SwiftDataProductionContainer.createInMemoryContainer())

        let context: ModelContext = swiftDatabase.openContext()

        context.insertObjects(objects: addSwiftObjects)

        try context.saveIfHasChanges()

        return TestsDiContainer(
            testsAppConfig: TestsAppConfig(
                swiftDatabase: swiftDatabase
            )
        )
    }

    @available(iOS 17.4, *)
    private func getUserLessonFilterLanguageUseCase(addSwiftObjects: [any PersistentModel]) throws -> GetUserLessonFilterLanguageUseCase {

        let testsDiContainer = try getTestsDiContainer(addSwiftObjects: addSwiftObjects)

        return getUserLessonFilterLanguageUseCase(testsDiContainer: testsDiContainer)
    }

    private func getUserLessonFilterLanguageUseCase(testsDiContainer: TestsDiContainer) -> GetUserLessonFilterLanguageUseCase {

        return GetUserLessonFilterLanguageUseCase(
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            userToolFilterSettingsRepository: testsDiContainer.core.dataLayer.getUserToolFilterSettingsRepository(),
            mapLanguageToLessonFilterLanguage: mapLanguageToLessonFilterLanguage(testsDiContainer: testsDiContainer)
        )
    }

    private func mapLanguageToLessonFilterLanguage(testsDiContainer: TestsDiContainer) -> MapLanguageToLessonFilterLanguage {
        return MapLanguageToLessonFilterLanguage(
            resourcesRepository: testsDiContainer.core.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.core.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: getStringWithLocaleCount()
        )
    }

    private func getLocalizationServices() -> FakeLocalizationServices {

        let localizableStrings: [FakeLocalizationServices.LocaleId: [FakeLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.french.rawValue: "Francés"
            ]
        ]

        return FakeLocalizationServices(localizableStrings: localizableStrings)
    }

    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {

        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageName: FakeLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: FakeLocaleLanguageName.getDefault(),
            localeRegionName: FakeLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: FakeLocaleLanguageScriptName(scriptNames: [:])
        )

        return getTranslatedLanguageName
    }

    private func getStringWithLocaleCount() -> StringWithLocaleCountInterface {

        return FakeStringWithLocaleCount()
    }
}
