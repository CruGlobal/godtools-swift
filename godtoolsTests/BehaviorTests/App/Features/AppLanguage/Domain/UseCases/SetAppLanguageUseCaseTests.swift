//
//  SetAppLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine
import RepositorySync

@Suite(.serialized)
struct SetAppLanguageUseCaseTests {
        
    @Test(
        """
        Given: User is viewing the language settings
        When: The app language is switched from English to Spanish
        Then: The user's lesson language filter should update to Spanish.
        """
    )
    @MainActor func setUserPreferredAppLanguageRepositoryTest() async throws {
        
        let allLanguages: [RealmLanguage] = getAllLanguages()
        
        let testsDiContainer = try getTestsDiContainer(
            addRealmObjects: allLanguages
        )
        
        let setAppLanguageUseCase = SetAppLanguageUseCase(
            userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
            userLessonFiltersRepository: testsDiContainer.dataLayer.getUserLessonFiltersRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository()
        )
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersUseCase(
            userLessonFiltersRepository: testsDiContainer.dataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguage: testsDiContainer.feature.lessonFilter.domainLayer.getLessonFilterLangauge()
        )
        
        let appLanguageSpanish = LanguageCodeDomainModel.spanish.rawValue
        let realmLanguageSpanish = allLanguages.first(where: { $0.code == appLanguageSpanish.languageCode })
                
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            getUserLessonFiltersRepository
                .execute(
                    appLanguage: appLanguageSpanish
                )
                .sink { (userLessonFilters: UserLessonFiltersDomainModel) in
                    
                    triggerCount += 1
                                    
                    if triggerCount == 2 {
                        
                        lessonLanguageFilterRef = userLessonFilters.languageFilter
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
            
            setAppLanguageUseCase
                .execute(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
                .sink(receiveCompletion: { completion in
                    
                }, receiveValue: { _ in
                    
                })
                .store(in: &cancellables)
        }
        
        #expect(realmLanguageSpanish != nil)
        #expect(lessonLanguageFilterRef?.languageId == realmLanguageSpanish?.id)
    }
}

extension SetAppLanguageUseCaseTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject]) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: SetAppLanguageUseCaseTests.self),
            addRealmObjects: addRealmObjects
        )
    }
    
    private func getAllLanguages() -> [RealmLanguage] {
        
        return [
            getRealmLanguage(languageCode: .afrikaans),
            getRealmLanguage(languageCode: .arabic),
            getRealmLanguage(languageCode: .chinese),
            getRealmLanguage(languageCode: .czech),
            getRealmLanguage(languageCode: .english),
            getRealmLanguage(languageCode: .french),
            getRealmLanguage(languageCode: .hebrew),
            getRealmLanguage(languageCode: .latvian),
            getRealmLanguage(languageCode: .portuguese),
            getRealmLanguage(languageCode: .russian),
            getRealmLanguage(languageCode: .spanish),
            getRealmLanguage(languageCode: .vietnamese)
        ]
    }
    
    private func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        
        return MockRealmLanguage.createLanguage(language: languageCode, name: languageCode.rawValue + " Name")
    }
    
    private func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LessonFilterStringKeys.lessonsAvailableText.rawValue: "lessons available"]
        ]
        
        return MockLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
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
