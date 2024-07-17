//
//  SearchAppLanguageInAppLanguagesListRepositoryTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class SearchAppLanguageInAppLanguagesListRepositoryTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is searching an app language in the app languages list.") {
            
            let searchAppLanguageList = SearchAppLanguageInAppLanguagesListRepository(
                stringSearcher: StringSearcher()
            )
            
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
            
            context("When inputing a single letter search text 'e'") {
                
                it("I expect to see languages containing the letter e in either language name translated in own language or language name translated in app language ignoring case sensitivity.") {
                                        
                    var resultRef: [AppLanguageListItemDomainModel] = Array()
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = searchAppLanguageList
                            .getSearchResultsPublisher(searchText: "e", appLanguagesList: appLanguagesList)
                            .sink { (result: [AppLanguageListItemDomainModel]) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    let expectedLanguages: [String] = ["zh-Hans", "zh-Hant", "en", "fr", "id", "lv", "pt", "es", "vi"]
                    
                    expect(resultRef.map({$0.language})).to(contain(expectedLanguages))
                }
            }
            
            context("When inputing a multi letter search text 'Ind'") {
                
                it("I expect to see languages containing the letters 'Ind' in either language name translated in own language or language name translated in app language ignoring case sensitivity.") {
                                        
                    var resultRef: [AppLanguageListItemDomainModel] = Array()
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = searchAppLanguageList
                            .getSearchResultsPublisher(searchText: "Ind", appLanguagesList: appLanguagesList)
                            .sink { (result: [AppLanguageListItemDomainModel]) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    let expectedLanguages: [String] = ["hi", "id"]
                    
                    expect(resultRef.map({$0.language})).to(contain(expectedLanguages))
                }
            }
        }
    }
}

