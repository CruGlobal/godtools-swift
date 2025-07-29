//
//  GetLessonFilterLanguagesInterfaceStringsRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetLessonFilterLanguagesInterfaceStringsRepositoryTests {
    
    @Test(
        """
        Given: User is viewing the lesson filter languages.
        When: The app language is switched from English to Spanish.
        Then: The interface strings should be translated into Spanish.
        """
    )
    func lessonFilterInterfaceStringsAreTranslatedWhenAppLanguageChanges() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let navTitleKey: String = LessonFilterStringKeys.navTitle.rawValue
        
        let localizableStrings: [MockLocalizationServices.LocaleId: [MockLocalizationServices.StringKey: String]] = [
            LanguageCodeDomainModel.english.value: [
                navTitleKey: "Lesson language"
            ],
            LanguageCodeDomainModel.spanish.value: [
                navTitleKey: "Idioma de la lección"
            ]
        ]
        
        let getLessonFilterLanguagesInterfaceStringsRepository = GetLessonFilterLanguagesInterfaceStringsRepository(
            localizationServices: MockLocalizationServices(localizableStrings: localizableStrings)
        )
        
        let appLanguagePublisher: CurrentValueSubject<AppLanguageDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
        
        var englishInterfaceStringsRef: LessonFilterLanguagesInterfaceStringsDomainModel?
        var spanishInterfaceStringsRef: LessonFilterLanguagesInterfaceStringsDomainModel?
        
        var sinkCount: Int = 0
        
        await confirmation(expectedCount: 2) { confirmation in
            
            appLanguagePublisher
                .flatMap({ (appLanguage: AppLanguageDomainModel) -> AnyPublisher<LessonFilterLanguagesInterfaceStringsDomainModel, Never> in
                    
                    return getLessonFilterLanguagesInterfaceStringsRepository
                        .getStringsPublisher(translateInAppLanguage: appLanguage)
                        .eraseToAnyPublisher()
                })
                .sink { (interfaceStrings: LessonFilterLanguagesInterfaceStringsDomainModel) in
                    
                    sinkCount += 1
                    confirmation()
                    
                    if sinkCount == 1 {
                        
                        englishInterfaceStringsRef = interfaceStrings
                        appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                    }
                    else if sinkCount == 2 {
                        
                        spanishInterfaceStringsRef = interfaceStrings
                    }
                }
                .store(in: &cancellables)
        }
        
        #expect(englishInterfaceStringsRef?.navTitle == "Lesson language")
        #expect(spanishInterfaceStringsRef?.navTitle == "Idioma de la lección")
    }
}
