//
//  SearchLanguageInDownloadableLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct SearchLanguageInDownloadableLanguagesUseCaseTests {
        
    @Test(
        """
        Given: User is searching a language in the downloadable languages list.
        When: The search text is a single letter 'c'.
        Then: I should see all languages that contain a letter 'c' whether it be in the language translated in own language or language translated in app language regardless of placement and case sensitivity.
        """
    )
    func searchingLanguagesWithSingleLetterSearchString() {
        
        let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase = getSearchLanguageInDownloadableLanguagesUseCase()
        let downloadableLanguagesList: [DownloadableLanguageListItemDomainModel] = getDownloadableLanguagesList()
        
        let searchedDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = searchLanguageInDownloadableLanguagesUseCase
            .execute(searchText: "c", downloadableLanguages: downloadableLanguagesList)

        let searchedLanguages: [String] = searchedDownloadableLanguages.map({$0.languageId})
        let expectedLanguageIds: [String] = ["1", "2", "4", "7"]
        
        #expect(searchedLanguages.elementsEqual(expectedLanguageIds))
    }
    
    @Test(
        """
        Given: User is searching a language in the downloadable languages list.
        When: The search text is multi-letter 'Ber'.
        Then: I should see all languages that contain 'Ber' whether it be in the language translated in own language or language translated in app language regardless of placement and case sensitivity.
        """
    )
    func searchingLanguagesWithMultiLetterSearchString() {
        
        let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase = getSearchLanguageInDownloadableLanguagesUseCase()
        let downloadableLanguagesList: [DownloadableLanguageListItemDomainModel] = getDownloadableLanguagesList()
                
        let searchedDownloadableLanguages: [DownloadableLanguageListItemDomainModel] = searchLanguageInDownloadableLanguagesUseCase
            .execute(searchText: "Ber", downloadableLanguages: downloadableLanguagesList)
        
        let searchedLanguages: [String] = searchedDownloadableLanguages.map({$0.languageId})
        let expectedLanguageIds: [String] = ["2", "6", "7"]
        
        #expect(searchedLanguages.elementsEqual(expectedLanguageIds))
    }
}

extension SearchLanguageInDownloadableLanguagesUseCaseTests {
    
    private func getSearchLanguageInDownloadableLanguagesUseCase() -> SearchLanguageInDownloadableLanguagesUseCase {
        
        return SearchLanguageInDownloadableLanguagesUseCase(
            stringSearcher: StringSearcher()
        )
    }
    
    private func getDownloadableLanguagesList() -> [DownloadableLanguageListItemDomainModel] {
        
        let downloadableLanguagesList = [
            DownloadableLanguageListItemDomainModel(
                languageId: "0",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Apple", nameInAppLanguage: "Orange"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "1",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Cherry", nameInAppLanguage: "Blue"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "2",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Strawberry", nameInAppLanguage: "Black"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "3",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Kiwi", nameInAppLanguage: "Yellow"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "4",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Pink", nameInAppLanguage: "Spinach"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "5",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Green", nameInAppLanguage: "Grape"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "6",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Berry", nameInAppLanguage: "Brown"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "7",
                languageNamePair: TranslatedLanguageNamePairDomainModel(nameInOwnLanguage: "Cucumber", nameInAppLanguage: "Purple"),
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            )
        ]
        
        return downloadableLanguagesList
    }
}
