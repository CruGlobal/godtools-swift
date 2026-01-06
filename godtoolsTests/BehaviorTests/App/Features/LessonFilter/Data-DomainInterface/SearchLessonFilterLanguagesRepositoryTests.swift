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
                .getSearchResultsPublisher(for: argument.searchString, in: allLessonFilterLanguages)
                .sink { (languages: [LessonFilterLanguageDomainModel]) in
                    
                    confirmation()
                    
                    searchedLanguages = languages.map({$0.languageNameTranslatedInAppLanguage})
                }
                .store(in: &cancellables)
        }
        
        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages))
    }
}

extension SearchLessonFilterLanguagesRepositoryTests {
    
    private var allLessonFilterLanguages: [LessonFilterLanguageDomainModel] {
        return [
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "blAnd", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "bran", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Canned", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Church", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "church", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "food", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Food", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "foody", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "land", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "may", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "pAnda", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "sanded", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soccer", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soCCer", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tan", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tanned", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "WAND", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "wander", lessonsAvailableText: "", lessonsAvailableCount: 0),
            LessonFilterLanguageDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Yellow", lessonsAvailableText: "", lessonsAvailableCount: 0)
        ]
    }
}
