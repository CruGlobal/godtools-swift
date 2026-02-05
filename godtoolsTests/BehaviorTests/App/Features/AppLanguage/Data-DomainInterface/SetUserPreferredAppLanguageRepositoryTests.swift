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
import RepositorySync

@Suite(.serialized)
struct SetUserPreferredAppLanguageRepositoryTests {
        
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
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var lessonLanguageFilterRef: LessonFilterLanguageDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            await withCheckedContinuation { continuation in
                
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continuation.resume(returning: ())
                }
                
                getUserLessonFiltersRepository
                    .getUserLessonLanguageFilterPublisher(
                        translatedInAppLanguage: appLanguageSpanish
                    )
                    .sink { (lessonFilterLanguage: LessonFilterLanguageDomainModel?) in
                        
                        sinkCount += 1
                        
                        // Place inside a sink or other async closure:
                        confirmation()
                                        
                        if sinkCount == 2 {
                            
                            lessonLanguageFilterRef = lessonFilterLanguage
                            
                            // When finished be sure to call:
                            timeoutTask.cancel()
                            continuation.resume(returning: ())
                        }
                    }
                    .store(in: &cancellables)
                
                setUserPreferredAppLanguageRepository
                    .setLanguagePublisher(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
                    .sink(receiveCompletion: { completion in
                        
                    }, receiveValue: { _ in
                        
                    })
                    .store(in: &cancellables)
            }
        }
        
        #expect(realmLanguageSpanish != nil)
        #expect(lessonLanguageFilterRef?.languageId == realmLanguageSpanish?.id)
    }
}

extension SetUserPreferredAppLanguageRepositoryTests {
    
    private func getTestsDiContainer(addRealmObjects: [IdentifiableRealmObject]) throws -> TestsDiContainer {
                
        return try TestsDiContainer(
            realmFileName: String(describing: SetUserPreferredAppLanguageRepositoryTests.self),
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
