//
//  GetUserLessonFiltersUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine
import RealmSwift
import RepositorySync

@Suite(.serialized)
struct GetUserLessonFiltersUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the language filter in the lessons list.
        When: A lesson language filter hasn't been selected by the user.
        Then: The lesson language filter should default to the current app language when lessons exist in the current app language.
        """
    )
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsExistInAppLanguage() async throws {
        
        let appLanguageSpanish: AppLanguageDomainModel = LanguageCodeDomainModel.spanish.rawValue
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let spanishLesson_0 = RealmResource()
        spanishLesson_0.id = "es-lesson-0"
        spanishLesson_0.resourceType = ResourceType.lesson.rawValue
        spanishLesson_0.addLanguage(language: spanishLanguage)
        
        let realmObjectsToAdd: [IdentifiableRealmObject] = [spanishLanguage, spanishLesson_0]
        
        let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase = try getUserLessonFiltersUseCase(addRealmObjects: realmObjectsToAdd)
                
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getUserLessonFiltersUseCase
                .execute(appLanguage: appLanguageSpanish)
                .sink { (userLessonFilters: UserLessonFiltersDomainModel) in
                        
                    lessonLanguageFilterRef = userLessonFilters.languageFilter
                             
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
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
    @MainActor func lessonsLanguageFilterDefaultsToAppLanguageWhenLessonsDontExistInAppLanguage() async throws {
        
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
        
        let realmObjectsToAdd: [IdentifiableRealmObject] = [spanishLanguage, frenchLanguage, spanishLesson_0, frenchTract_0]
        
        let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase = try getUserLessonFiltersUseCase(addRealmObjects: realmObjectsToAdd)
                
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getUserLessonFiltersUseCase
                .execute(appLanguage: appLanguageFrench)
                .sink { (userLessonFilters: UserLessonFiltersDomainModel) in
                        
                    lessonLanguageFilterRef = userLessonFilters.languageFilter
                                     
                    // When finished be sure to call:
                    timeoutTask.cancel()
                    continuation.resume(returning: ())
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
    @MainActor func lessonsLanguageFilterIsTheSelectedLanguageFilterAndNotDefaultingAppLanguage() async throws {
                
        let appLanguageFrench: AppLanguageDomainModel = LanguageCodeDomainModel.french.rawValue
        
        let spanishLanguage = RealmLanguage()
        spanishLanguage.id = "0"
        spanishLanguage.code = LanguageCodeDomainModel.spanish.rawValue
        spanishLanguage.name = "Spanish Name"
        
        let frenchLanguage = RealmLanguage()
        frenchLanguage.id = "1"
        frenchLanguage.code = LanguageCodeDomainModel.french.rawValue
        frenchLanguage.name = "French Name"
        
        let realmObjectsToAdd: [IdentifiableRealmObject] = [spanishLanguage, frenchLanguage]
        
        let testsDiContainer: TestsDiContainer = try getTestsDiContainer(addRealmObjects: realmObjectsToAdd)
        
        let getUserLessonFiltersUseCase: GetUserLessonFiltersUseCase = getUserLessonFiltersUseCase(testsDiContainer: testsDiContainer)
                
        var originalLessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        var selectedLessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getUserLessonFiltersUseCase
                .execute(appLanguage: appLanguageFrench)
                .sink { (userLessonFilters: UserLessonFiltersDomainModel) in
                                        
                    triggerCount += 1
                                            
                    if triggerCount == 1 {
                        
                        originalLessonLanguageFilterRef = userLessonFilters.languageFilter
                        testsDiContainer.dataLayer.getUserLessonFiltersRepository().storeUserLessonLanguageFilter(with: spanishLanguage.id)
                    }
                    else if triggerCount == 2 {
                        
                        selectedLessonLanguageFilterRef = userLessonFilters.languageFilter
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
                
        #expect(originalLessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Français")
        #expect(originalLessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Français")
        
        #expect(selectedLessonLanguageFilterRef?.languageNameTranslatedInLanguage == "Español")
        #expect(selectedLessonLanguageFilterRef?.languageNameTranslatedInAppLanguage == "Espagnol")
    }
}

extension GetUserLessonFiltersUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject]) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: GetUserLessonFiltersUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getUserLessonFiltersUseCase(addRealmObjects: [IdentifiableRealmObject]) throws -> GetUserLessonFiltersUseCase {
        
        let testsDiContainer = try getTestsDiContainer(addRealmObjects: addRealmObjects)
        
        return getUserLessonFiltersUseCase(testsDiContainer: testsDiContainer)
    }
    
    private func getUserLessonFiltersUseCase(testsDiContainer: TestsDiContainer) -> GetUserLessonFiltersUseCase {
                
        return GetUserLessonFiltersUseCase(
            userLessonFiltersRepository: testsDiContainer.dataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguage: getLessonFilterLangauge(testsDiContainer: testsDiContainer)
        )
    }
    
    private func getLessonFilterLangauge(testsDiContainer: TestsDiContainer) -> GetLessonFilterLanguage {
        return GetLessonFilterLanguage(
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
            localizationLanguageName: MockLocalizationLanguageNameRepository(localizationServices: getLocalizationServices()),
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
