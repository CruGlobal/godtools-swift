//
//  SearchLessonFilterLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchLessonFilterLanguagesUseCaseTests {
        
    struct TestArgument {
        let searchString: String
        let expectedLanguages: [String]
    }
    
    @Test(
        """
        Given: User is searching a category in the tools filter categories list.
        When: User inputs a search string."
        Then: I expect to see all categories that contain the search string ignoring case.
        """,
        arguments: [
            TestArgument(
                searchString: "c",
                expectedLanguages: ["Canned", "Church", "church", "soccer", "soCCer"]
            ),
            TestArgument(
                searchString: "Y",
                expectedLanguages: ["foody", "may", "Yellow"]
            ),
            TestArgument(
                searchString: "anD",
                expectedLanguages: ["blAnd", "land", "pAnda", "sanded", "WAND", "wander"]
            )
        ]
    )
    func showsLessonFilterLanguagesContainingSearchString(argument: TestArgument) {
        
        let searchLessonFilterLanguagesUseCase = SearchLessonFilterLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
                
        let searchedLanguages: [String] = searchLessonFilterLanguagesUseCase
            .execute(searchText: argument.searchString, lessonFilterLanguages: allLessonFilterLanguages)
            .map({$0.languageNamePair.nameInAppLanguage})
        
        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages))
    }
}

extension SearchLessonFilterLanguagesUseCaseTests {
    
    private var allLessonFilterLanguages: [LessonFilterLanguageDomainModel] {
        return [
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "blAnd"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "bran"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Canned"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Church"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "church"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "food"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Food"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "foody"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "land"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "may"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "pAnda"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "sanded"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "soccer"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "soCCer"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Tan"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Tanned"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "WAND"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "wander"), lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "", languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "", nameInAppLanguage: "Yellow"), lessonsAvailableText: "", lessonsAvailableCount: 0)
        ]
    }
}
