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
            .map({$0.languageNameTranslatedInAppLanguage})
        
        #expect(argument.expectedLanguages.elementsEqual(searchedLanguages))
    }
}

extension SearchLessonFilterLanguagesUseCaseTests {
    
    private var allLessonFilterLanguages: [ToolLanguageFilterItemDomainModel] {
        return [
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "blAnd", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "bran", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Canned", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Church", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "church", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "food", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Food", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "foody", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "land", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "may", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "pAnda", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "sanded", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soccer", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "soCCer", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tan", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Tanned", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "WAND", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "wander", availableText: "", availableCount: 0),
            ToolLanguageFilterItemDomainModel(languageId: "",  languageNameTranslatedInLanguage: "", languageNameTranslatedInAppLanguage: "Yellow", availableText: "", availableCount: 0)
        ]
    }
}
