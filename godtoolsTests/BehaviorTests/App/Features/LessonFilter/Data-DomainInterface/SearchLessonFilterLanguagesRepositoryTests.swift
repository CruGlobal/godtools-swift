//
//  SearchLessonFilterLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/12/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchLessonFilterLanguagesRepositoryTests {
        
    private static let allLessonFilterLanguages: [LessonFilterLanguageDomainModel] = [
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "blAnd", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "bran", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Canned", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Church", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "church", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "food", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Food", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "foody", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "land", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "may", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "pAnda", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "sanded", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soccer", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soCCer", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tan", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tanned", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "WAND", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "wander", lessonsAvailableText: ""),
        LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Yellow", lessonsAvailableText: "")
    ]
    
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
    func showsLessonFilterLanguagesContainingSearchString(argument: TestArgument) async {
        
        let searchLessonFilterLanguagesRepository = SearchLessonFilterLanguagesRepository(
            stringSearcher: StringSearcher()
        )
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var searchedLanguages: [String] = Array()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            searchLessonFilterLanguagesRepository
                .getSearchResultsPublisher(for: argument.searchString, in: Self.allLessonFilterLanguages)
                .sink { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    confirmation()
                    
                    searchedLanguages = languages.map({$0.languageNameTranslatedInAppLanguage})
                }
                .store(in: &cancellables)
        }
        
        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages))
    }
}
