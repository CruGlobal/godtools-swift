//
//  SearchLanguageInDownloadableLanguagesRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class SearchLanguageInDownloadableLanguagesRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        var cancellables: Set<AnyCancellable> = Set()
        
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
        
        let searchLanguageInDownloadableLanguages = SearchLanguageInDownloadableLanguagesRepository(
            stringSearcher: StringSearcher()
        )
        
        describe("User is searching a language in the downloadable languages list.") {
            
            context("When the search text is a single letter 'c'.") {
                
                it("I should see all languages that contain a letter 'c' whether it be in the language translated in own language or language translated in app language regardless of placement and case sensitivity.") {
                    
                    var resultRef: [DownloadableLanguageListItemDomainModel] = Array()
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLanguageInDownloadableLanguages
                            .getSearchResultsPublisher(searchText: "c", downloadableLanguagesList: downloadableLanguagesList)
                            .sink { (result: [DownloadableLanguageListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                                        
                    let expectedLanguageIds: [String] = ["1", "2", "4", "7"]
                    
                    expect(resultRef.map({$0.languageId})).to(contain(expectedLanguageIds))
                }
            }
            
            context("When the search text is multi-letter 'Ber'.") {
                
                it("I should see all languages that contain 'Ber' whether it be in the language translated in own language or language translated in app language regardless of placement and case sensitivity.") {
                    
                    var resultRef: [DownloadableLanguageListItemDomainModel] = Array()
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        searchLanguageInDownloadableLanguages
                            .getSearchResultsPublisher(searchText: "Ber", downloadableLanguagesList: downloadableLanguagesList)
                            .sink { (result: [DownloadableLanguageListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                            .store(in: &cancellables)
                    }
                                        
                    let expectedLanguageIds: [String] = ["2", "6", "7"]
                    
                    expect(resultRef.map({$0.languageId})).to(contain(expectedLanguageIds))
                }
            }
        }
    }
}

