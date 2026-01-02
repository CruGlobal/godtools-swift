//
//  GetUserLessonFiltersRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RealmSwift

struct GetUserLessonFiltersRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: A lesson language filter hasn't been selected by the user.
        Then: The lesson language filter should default to the current app language when lessons exist in the current app language.
        """
    )
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsExistInAppLanguage() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let spanishLesson_0 = RealmResource()
        spanishLesson_0.id = "es-lesson-0"
        spanishLesson_0.resourceType = ResourceType.lesson.rawValue
        spanishLesson_0.addLanguage(language: spanishLanguage)
        
        let realmObjectsToAdd: [Object] = [spanishLanguage, spanishLesson_0]
        
        let testsDiContainer = TestsDiContainer(
            realmDatabase: getRealmDatabase(addRealmObjects: realmObjectsToAdd)
        )
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
            userLessonFiltersRepository: getUserLessonFiltersRepository(testsDiContainer: testsDiContainer),
            getLessonFilterLanguagesRepository: getLessonFilterLanguagesRepository(testsDiContainer: testsDiContainer)
        )
        
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserLessonFiltersRepository
                .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageSpanish)
                .sink { (lessonLanguageFilter: LessonFilterLanguageDomainModel?) in
                        
                    confirmation()

                    lessonLanguageFilterRef = lessonLanguageFilter
                }
                .store(in: &cancellables)
        }
        
        #expect(lessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Español")
        #expect(lessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Español")
    }
    
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: A lesson language filter hasn't been selected by the user.
        Then: The lesson language filter should default to the current app language even when lessons don't exist in the current app language.
        """
    )
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsDontExistInAppLanguage() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageFrench: AppLanguageDomainModel = LanguageCodeDomainModel.french.rawValue
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let frenchLanguage = RealmLanguage()
        frenchLanguage.id = "1"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"
        
        let spanishLesson_0 = RealmResource()
        spanishLesson_0.id = "es-lesson-0"
        spanishLesson_0.resourceType = ResourceType.lesson.rawValue
        spanishLesson_0.addLanguage(language: spanishLanguage)
        
        let frenchTract_0 = RealmResource()
        frenchTract_0.id = "fr-lesson-0"
        frenchTract_0.resourceType = ResourceType.tract.rawValue
        frenchTract_0.addLanguage(language: frenchLanguage)
        
        let realmObjectsToAdd: [Object] = [spanishLanguage, frenchLanguage, spanishLesson_0, frenchTract_0]
        
        let testsDiContainer = TestsDiContainer(
            realmDatabase: getRealmDatabase(addRealmObjects: realmObjectsToAdd)
        )
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
            userLessonFiltersRepository: getUserLessonFiltersRepository(testsDiContainer: testsDiContainer),
            getLessonFilterLanguagesRepository: getLessonFilterLanguagesRepository(testsDiContainer: testsDiContainer)
        )
        
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
                
        await confirmation(expectedCount: 1) { confirmation in
            
            getUserLessonFiltersRepository
                .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageFrench)
                .sink { (lessonLanguageFilter: LessonFilterLanguageDomainModel?) in
                        
                    confirmation()

                    lessonLanguageFilterRef = lessonLanguageFilter
                }
                .store(in: &cancellables)
        }
        
        #expect(lessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Français")
        #expect(lessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Français")
    }
    
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: The app language is french and the user has selected lesson language filter spanish.
        Then: The lesson language filter should be spanish.
        """
    )
    @MainActor func lessonsLanguageFilterIsTheSelectedLanguageFilterAndNotDefaultingAppLanguage() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let appLanguageFrench: AppLanguageDomainModel = LanguageCodeDomainModel.french.rawValue
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let frenchLanguage = RealmLanguage()
        frenchLanguage.id = "1"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"
        
        let testsDiContainer = TestsDiContainer(
            realmDatabase: getRealmDatabase(addRealmObjects: [spanishLanguage, frenchLanguage])
        )
        
        let userLessonFiltersRepository: UserLessonFiltersRepository = getUserLessonFiltersRepository(testsDiContainer: testsDiContainer)
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
            userLessonFiltersRepository: userLessonFiltersRepository,
            getLessonFilterLanguagesRepository: getLessonFilterLanguagesRepository(testsDiContainer: testsDiContainer)
        )
        
        var originalLessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        var selectedLessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        var sinkCount: Int = 0
    
        await confirmation(expectedCount: 2) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let task = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserLessonFiltersRepository
                    .getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageFrench)
                    .sink { (lessonLanguageFilter: LessonFilterLanguageDomainModel?) in
                        
                        confirmation()
                        
                        sinkCount += 1
                                                
                        if sinkCount == 1 {
                            
                            originalLessonLanguageFilterRef = lessonLanguageFilter
                            userLessonFiltersRepository.storeUserLessonLanguageFilter(with: spanishLanguage.id)
                        }
                        else if sinkCount == 2 {
                            selectedLessonLanguageFilterRef = lessonLanguageFilter
                            task.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
            }
        }
                
        #expect(originalLessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Français")
        #expect(originalLessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Français")
        
        #expect(selectedLessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Español")
        #expect(selectedLessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Espagnol")
    }
}

extension GetUserLessonFiltersRepositoryTests {
    
    private func getRealmDatabase(addRealmObjects: [Object]) -> LegacyRealmDatabase {
        return TestsInMemoryRealmDatabase(
            addObjectsToDatabase: addRealmObjects
        )
    }
    
    @MainActor private func getUserLessonFiltersRepository(testsDiContainer: TestsDiContainer) -> UserLessonFiltersRepository {
        
        return testsDiContainer.dataLayer.getUserLessonFiltersRepository()
    }
    
    @MainActor private func getLessonFilterLanguagesRepository(testsDiContainer: TestsDiContainer) -> GetLessonFilterLanguagesRepository {
        
        return GetLessonFilterLanguagesRepository(
            resourcesRepository: testsDiContainer.dataLayer.getResourcesRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository(),
            getTranslatedLanguageName: getTranslatedLanguageName(),
            localizationServices: getLocalizationServices(),
            stringWithLocaleCount: getStringWithLocaleCount()
        )
    }
    
    private func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.spanish.value: [
                LanguageCodeDomainModel.french.rawValue: "Francés"
            ]
        ]
        
        return MockLocalizationServices(localizableStrings: localizableStrings)
    }

    private func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
    
    private func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        
        return MockStringWithLocaleCount()
    }
}
