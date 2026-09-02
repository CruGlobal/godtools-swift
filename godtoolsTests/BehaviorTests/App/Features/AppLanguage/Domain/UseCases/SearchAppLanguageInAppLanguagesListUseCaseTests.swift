//
//  SearchAppLanguageInAppLanguagesListUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct SearchAppLanguageInAppLanguagesListUseCaseTests {
    
    @Test(
        """
        Given: User is searching an app language in the app languages list.
        When: Inputing a single letter search text 'e'.
        Then: I expect to see languages containing the letter e in either language name translated in own language or language name translated in app language ignoring case sensitivity.
        """
    )
    func searchingAppLanguagesWithSingleLetterSearchString() {
        
        let searchAppLanguageList: SearchAppLanguageInAppLanguagesListUseCase = getSearchAppLanguageInAppLanguagesListUseCase()
        let appLanguagesList: [AppLanguageListItemDomainModel] = getAppLanguagesList()
                
        let searchResult: [AppLanguageListItemDomainModel] = searchAppLanguageList
            .execute(searchText: "e", appLanguagesList: appLanguagesList)
        
        let searchedLanguages: [String] = searchResult.map({$0.language})
        let expectedLanguages: [String] = ["zh-Hans", "zh-Hant", "en", "fr", "id", "lv", "pt", "es", "vi"]
        
        
        #expect(searchedLanguages.elementsEqual(expectedLanguages))
    }
    
    @Test(
        """
        Given: User is searching an app language in the app languages list.
        When: Inputing a multi letter search text 'Ind'".
        Then: I expect to see languages containing the letters 'Ind' in either language name translated in own language or language name translated in app language ignoring case sensitivity.
        """
    )
    func searchingAppLanguagesWithMultiLetterSearchString() {
        
        let searchAppLanguageList: SearchAppLanguageInAppLanguagesListUseCase = getSearchAppLanguageInAppLanguagesListUseCase()
        let appLanguagesList: [AppLanguageListItemDomainModel] = getAppLanguagesList()
                
        let searchResult: [AppLanguageListItemDomainModel] = searchAppLanguageList
            .execute(searchText: "Ind", appLanguagesList: appLanguagesList)
        
        let searchedLanguages: [String] = searchResult.map({$0.language})
        let expectedLanguages: [String] = ["hi", "id"]
        
        #expect(searchedLanguages.elementsEqual(expectedLanguages))
    }
}

extension SearchAppLanguageInAppLanguagesListUseCaseTests {
    
    private func getSearchAppLanguageInAppLanguagesListUseCase() -> SearchAppLanguageInAppLanguagesListUseCase {
        
        let searchAppLanguageList = SearchAppLanguageInAppLanguagesListUseCase(
            stringSearcher: StringSearcher()
        )
        
        return searchAppLanguageList
    }
    
    private func getAppLanguagesList() -> [AppLanguageListItemDomainModel] {
        
        let appLanguagesList: [AppLanguageListItemDomainModel] = [
            AppLanguageListItemDomainModel(
                language: "ar",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "العربية", nameInAppLanguage: "Arabic")
            ),
            AppLanguageListItemDomainModel(
                language: "bn",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "বাংলা", nameInAppLanguage: "Bangla")
            ),
            AppLanguageListItemDomainModel(
                language: "zh-Hans",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "中文 (简体中文)", nameInAppLanguage: "Chinese (Simplified Han)")
            ),
            AppLanguageListItemDomainModel(
                language: "zh-Hant",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "中文 (繁體中文", nameInAppLanguage: "Chinese (Traditional Han)")
            ),
            AppLanguageListItemDomainModel(
                language: "en",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "English", nameInAppLanguage: "English")
            ),
            AppLanguageListItemDomainModel(
                language: "fr",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "français", nameInAppLanguage: "French")
            ),
            AppLanguageListItemDomainModel(
                language: "hi",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "हिन्दी", nameInAppLanguage: "Hindi")
            ),
            AppLanguageListItemDomainModel(
                language: "id",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Indonesia", nameInAppLanguage: "Indonesian")
            ),
            AppLanguageListItemDomainModel(
                language: "lv",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "latviešu", nameInAppLanguage: "Latvian")
            ),
            AppLanguageListItemDomainModel(
                language: "pt",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "português", nameInAppLanguage: "Portuguese")
            ),
            AppLanguageListItemDomainModel(
                language: "ru",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "русский", nameInAppLanguage: "Russian")
            ),
            AppLanguageListItemDomainModel(
                language: "es",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "español", nameInAppLanguage: "Spanish")
            ),
            AppLanguageListItemDomainModel(
                language: "ur",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "اردو", nameInAppLanguage: "Urdu")
            ),
            AppLanguageListItemDomainModel(
                language: "vi",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Tiếng Việt", nameInAppLanguage: "Vietnamese")
            )
        ]
        
        return appLanguagesList
    }
}
