//
//  SetUserPreferredAppLanguageRepositoryTests.swift
//  godtoolsTests
//
//  Created by Rachael Skeath on 8/2/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
import Foundation
@testable import godtools
import Combine

struct SetUserPreferredAppLanguageRepositoryTests {
        
    @Test(
        """
        Given: User is viewing the language settings
        When: The app language is switched from English to Spanish
        Then: The user's lesson language filter should update to Spanish.
        """
    )
    @MainActor func setUserPreferredAppLanguageRepositoryTest() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let allLanguages: [RealmLanguage] = SetUserPreferredAppLanguageRepositoryTests.getAllLanguages()
        
        let realmDatabase: RealmDatabase = TestsInMemoryRealmDatabase(
            addObjectsToDatabase: allLanguages
        )
        
        let testsDiContainer = TestsDiContainer(realmDatabase: realmDatabase)
        
        let setUserPreferredAppLanguageRepository = SetUserPreferredAppLanguageRepository(
            userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
            userLessonFiltersRepository: testsDiContainer.dataLayer.getUserLessonFiltersRepository(),
            languagesRepository: testsDiContainer.dataLayer.getLanguagesRepository()
        )
        
        let getUserLessonFiltersRepository = GetUserLessonFiltersRepository(
            userLessonFiltersRepository: testsDiContainer.dataLayer.getUserLessonFiltersRepository(),
            getLessonFilterLanguagesRepository: testsDiContainer.feature.lessonFilter.dataLayer.getLessonFilterLanguagesRepository()
        )
        
        let appLanguageSpanish = LanguageCodeDomainModel.spanish.rawValue
        let realmLanguageSpanish = allLanguages.first(where: { $0.code == appLanguageSpanish.languageCode })
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        await confirmation(expectedCount: 1) { confirmation in
            
            setUserPreferredAppLanguageRepository.setLanguagePublisher(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
                .flatMap { _ in
                    
                    return getUserLessonFiltersRepository.getUserLessonLanguageFilterPublisher(translatedInAppLanguage: appLanguageSpanish)
                }
                .sink { lessonFilterLanguage in
                    
                    confirmation()
                    lessonLanguageFilterRef = lessonFilterLanguage
                }
                .store(in: &cancellables)
        }
        
        #expect(realmLanguageSpanish != nil)
        #expect(lessonLanguageFilterRef?.languageId == realmLanguageSpanish?.id)
    }
    
    private static func getAllLanguages() -> [RealmLanguage] {
        
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
}

extension SetUserPreferredAppLanguageRepositoryTests {
    
    private static func getRealmLanguage(languageCode: LanguageCodeDomainModel) -> RealmLanguage {
        
        return MockRealmLanguage.getLanguage(language: languageCode, name: languageCode.rawValue + " Name")
    }
    
    private static func getLocalizationServices() -> MockLocalizationServices {
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.rawValue: [LessonFilterStringKeys.lessonsAvailableText.rawValue: "lessons available"]
        ]
        
        return MockLocalizationServices.createLanguageNamesLocalizationServices(
            addAdditionalLocalizableStrings: localizableStrings
        )
    }
    
    private static func getTranslatedLanguageName() -> GetTranslatedLanguageName {
        
        let getTranslatedLanguageName = GetTranslatedLanguageName(
            localizationLanguageNameRepository: MockLocalizationLanguageNameRepository(localizationServices: SetUserPreferredAppLanguageRepositoryTests.getLocalizationServices()),
            localeLanguageName: MockLocaleLanguageName.defaultMockLocaleLanguageName(),
            localeRegionName: MockLocaleLanguageRegionName(regionNames: [:]),
            localeScriptName: MockLocaleLanguageScriptName(scriptNames: [:])
        )
        
        return getTranslatedLanguageName
    }
    
    private static func getStringWithLocaleCount() -> StringWithLocaleCountInterface {
        
        return MockStringWithLocaleCount()
    }
}
