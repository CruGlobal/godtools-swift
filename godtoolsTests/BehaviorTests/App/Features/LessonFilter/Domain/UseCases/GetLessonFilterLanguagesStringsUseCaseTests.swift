//
//  GetLessonFilterLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetLessonFilterLanguagesStringsUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the lesson filter languages.
        When: The app language is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    func lessonFilterStringsAreTranslatedWhenAppLanguageChanges() async {
                
        let navTitleKey: String = LessonFilterStringKeys.navTitle.rawValue
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                navTitleKey: "Lesson language"
            ],
            LanguageCodeDomainModel.spanish.value: [
                navTitleKey: "Idioma de la lección"
            ]
        ]
        
        let getLessonFilterLanguagesStringsUseCase = GetLessonFilterLanguagesStringsUseCase(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishStringsRef: LessonFilterLanguagesStringsDomainModel?
        var spanishStringsRef: LessonFilterLanguagesStringsDomainModel?
        
        var cancellables: Set<AnyCancellable> = Set()
        var triggerCount: Int = 0
        
        await withCheckedContinuation { continuation in
            
            let timeoutTask = Task {
                try await Task.defaultTestSleep()
                continuation.resume(returning: ())
            }
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesStringsDomainModel, Never> in
                    
                    return getLessonFilterLanguagesStringsUseCase
                        .execute(appLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink { (strings: LessonFilterLanguagesStringsDomainModel) in
                    
                    triggerCount += 1
                    
                    if triggerCount == 1 {
                        
                        englishStringsRef = strings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if triggerCount == 2 {
                        
                        spanishStringsRef = strings
                        
                        // When finished be sure to call:
                        timeoutTask.cancel()
                        continuation.resume(returning: ())
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishStringsRef?.navTitle == "Lesson language")
        #expect(spanishStringsRef?.navTitle == "Idioma de la lección")
    }
}
