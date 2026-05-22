//
//  GetLessonFilterLanguagesStringsUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetLessonFilterLanguagesStringsUseCaseTests {
    
    @Test(
        """
        Given: User is viewing the lesson filter languages.
        When: The app language is set to Spanish.
        Then: The interface strings should be translated in Spanish.
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
        
        let strings = getLessonFilterLanguagesStringsUseCase
            .execute(appLanguage: LanguageCodeDomainModel.spanish.rawValue)
        
        #expect(strings.navTitle == "Idioma de la lección")
    }
}
