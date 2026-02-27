//
//  SearchLanguageInDownloadableLanguagesUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct SearchLanguageInDownloadableLanguagesUseCaseTests {
        
    @Test(
        """
        Given: User is searching a language in the downloadable languages list.
        When: The search text is a single letter 'c'.
        Then: I should see all languages that contain a letter 'c' whether it be in the language translated in own language or language translated in app language regardless of placement and case sensitivity.
        """
    )
    func searchingLanguagesWithSingleLetterSearchString() async {
        
        let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase = getSearchLanguageInDownloadableLanguagesUseCase()
        let downloadableLanguagesList: [DownloadableLanguageListItemDomainModel] = getDownloadableLanguagesList()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var resultRef: [DownloadableLanguageListItemDomainModel] = Array()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            searchLanguageInDownloadableLanguagesUseCase
                .execute(searchText: "c", downloadableLanguages: downloadableLanguagesList)
                .sink { (result: [DownloadableLanguageListItemDomainModel]) in
                    
                    confirmation()
                    
                    resultRef = result
                }
                .store(in: &cancellables)
        }
        
        let searchedLanguages: [String] = resultRef.map({$0.languageId})
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
    func searchingLanguagesWithMultiLetterSearchString() async {
        
        let searchLanguageInDownloadableLanguagesUseCase: SearchLanguageInDownloadableLanguagesUseCase = getSearchLanguageInDownloadableLanguagesUseCase()
        let downloadableLanguagesList: [DownloadableLanguageListItemDomainModel] = getDownloadableLanguagesList()
        
        var cancellables: Set<AnyCancellable> = Set()
        
        var resultRef: [DownloadableLanguageListItemDomainModel] = Array()
                
        await confirmation(expectedCount: 1) { confirmation in
            
            searchLanguageInDownloadableLanguagesUseCase
                .execute(searchText: "Ber", downloadableLanguages: downloadableLanguagesList)
                .sink { (result: [DownloadableLanguageListItemDomainModel]) in
                    
                    confirmation()
                    
                    resultRef = result
                }
                .store(in: &cancellables)
        }
        
        let searchedLanguages: [String] = resultRef.map({$0.languageId})
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
                languageNameInOwnLanguage: "Apple",
                languageNameInAppLanguage: "Orange",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "1",
                languageNameInOwnLanguage: "Cherry",
                languageNameInAppLanguage: "Blue",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "2",
                languageNameInOwnLanguage: "Strawberry",
                languageNameInAppLanguage: "Black",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "3",
                languageNameInOwnLanguage: "Kiwi",
                languageNameInAppLanguage: "Yellow",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "4",
                languageNameInOwnLanguage: "Pink",
                languageNameInAppLanguage: "Spinach",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "5",
                languageNameInOwnLanguage: "Green",
                languageNameInAppLanguage: "Grape",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "6",
                languageNameInOwnLanguage: "Berry",
                languageNameInAppLanguage: "Brown",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            ),
            DownloadableLanguageListItemDomainModel(
                languageId: "7",
                languageNameInOwnLanguage: "Cucumber",
                languageNameInAppLanguage: "Purple",
                toolsAvailableText: "",
                downloadStatus: .notDownloaded
            )
        ]
        
        return downloadableLanguagesList
    }
}
