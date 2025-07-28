//
//  SearchAppLanguageInAppLanguagesListRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchAppLanguageInAppLanguagesListRepositoryTests {
    
    private static let searchAppLanguageList: SearchAppLanguageInAppLanguagesListRepository = getSearchAppLanguageInAppLanguagesListRepository()
    private static let appLanguagesList: [AppLanguageListItemDomainModel] = getAppLanguagesList()
    
    @Test(
        """
        Given: User is searching an app language in the app languages list.
        When: Inputing a single letter search text 'e'.
        Then: I expect to see languages containing the letter e in either language name translated in own language or language name translated in app language ignoring case sensitivity.
        """
    )
    func searchingAppLanguagesWithSingleLetterSearchString() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var resultRef: [AppLanguageListItemDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.searchAppLanguageList
                .getSearchResultsPublisher(searchText: "e", appLanguagesList: Self.appLanguagesList)
                .sink { (result: [AppLanguageListItemDomainModel]) in
                
                    confirmation()
                    
                    resultRef = result
                }
                .store(in: &cancellables)
        }
        
        let searchedLanguages: [String] = resultRef.map({$0.language})
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
    func searchingAppLanguagesWithMultiLetterSearchString() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var resultRef: [AppLanguageListItemDomainModel] = Array()
        
        await confirmation(expectedCount: 1) { confirmation in
            
            Self.searchAppLanguageList
                .getSearchResultsPublisher(searchText: "Ind", appLanguagesList: Self.appLanguagesList)
                .sink { (result: [AppLanguageListItemDomainModel]) in
                
                    confirmation()
                    
                    resultRef = result
                }
                .store(in: &cancellables)
        }
        
        let searchedLanguages: [String] = resultRef.map({$0.language})
        let expectedLanguages: [String] = ["hi", "id"]
        
        #expect(searchedLanguages.elementsEqual(expectedLanguages))
    }
}

extension SearchAppLanguageInAppLanguagesListRepositoryTests {
    
    private static func getSearchAppLanguageInAppLanguagesListRepository() -> SearchAppLanguageInAppLanguagesListRepository {
        
        let searchAppLanguageList = SearchAppLanguageInAppLanguagesListRepository(
            stringSearcher: StringSearcher()
        )
        
        return searchAppLanguageList
    }
    
    private static func getAppLanguagesList() -> [AppLanguageListItemDomainModel] {
        
        let appLanguagesList: [AppLanguageListItemDomainModel] = [
            AppLanguageListItemDomainModel(
                language: "ar",
                languageNameTranslatedInOwnLanguage: "العربية",
                languageNameTranslatedInCurrentAppLanguage: "Arabic"
            ),
            AppLanguageListItemDomainModel(
                language: "bn",
                languageNameTranslatedInOwnLanguage: "বাংলা",
                languageNameTranslatedInCurrentAppLanguage: "Bangla"
            ),
            AppLanguageListItemDomainModel(
                language: "zh-Hans",
                languageNameTranslatedInOwnLanguage: "中文 (简体中文)",
                languageNameTranslatedInCurrentAppLanguage: "Chinese (Simplified Han)"
            ),
            AppLanguageListItemDomainModel(
                language: "zh-Hant",
                languageNameTranslatedInOwnLanguage: "中文 (繁體中文",
                languageNameTranslatedInCurrentAppLanguage: "Chinese (Traditional Han)"
            ),
            AppLanguageListItemDomainModel(
                language: "en",
                languageNameTranslatedInOwnLanguage: "English",
                languageNameTranslatedInCurrentAppLanguage: "English"
            ),
            AppLanguageListItemDomainModel(
                language: "fr",
                languageNameTranslatedInOwnLanguage: "français",
                languageNameTranslatedInCurrentAppLanguage: "French"
            ),
            AppLanguageListItemDomainModel(
                language: "hi",
                languageNameTranslatedInOwnLanguage: "हिन्दी",
                languageNameTranslatedInCurrentAppLanguage: "Hindi"
            ),
            AppLanguageListItemDomainModel(
                language: "id",
                languageNameTranslatedInOwnLanguage: "Indonesia",
                languageNameTranslatedInCurrentAppLanguage: "Indonesian"
            ),
            AppLanguageListItemDomainModel(
                language: "lv",
                languageNameTranslatedInOwnLanguage: "latviešu",
                languageNameTranslatedInCurrentAppLanguage: "Latvian"
            ),
            AppLanguageListItemDomainModel(
                language: "pt",
                languageNameTranslatedInOwnLanguage: "português",
                languageNameTranslatedInCurrentAppLanguage: "Portuguese"
            ),
            AppLanguageListItemDomainModel(
                language: "ru",
                languageNameTranslatedInOwnLanguage: "русский",
                languageNameTranslatedInCurrentAppLanguage: "Russian"
            ),
            AppLanguageListItemDomainModel(
                language: "es",
                languageNameTranslatedInOwnLanguage: "español",
                languageNameTranslatedInCurrentAppLanguage: "Spanish"
            ),
            AppLanguageListItemDomainModel(
                language: "ur",
                languageNameTranslatedInOwnLanguage: "اردو",
                languageNameTranslatedInCurrentAppLanguage: "Urdu"
            ),
            AppLanguageListItemDomainModel(
                language: "vi",
                languageNameTranslatedInOwnLanguage: "Tiếng Việt",
                languageNameTranslatedInCurrentAppLanguage: "Vietnamese"
            )
        ]
        
        return appLanguagesList
    }
}
