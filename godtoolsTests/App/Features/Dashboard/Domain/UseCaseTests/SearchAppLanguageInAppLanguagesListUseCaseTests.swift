//
//  SearchAppLanguageInAppLanguagesListUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class SearchAppLanguageInAppLanguagesListUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is searching for an app language in the app languages list.") {
         
            context("When the search string is the character 'c'") {
                                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.czech, .spanish, .french, .chinese, .english, .russian])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                let getLanguageNameInEnglishRepository = TestsGetLanguageNameInEnglishRepository()
                
                let getAppLanguagesListUseCase = GetAppLanguagesListUseCase(
                    getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                    getAppLanguageNameUseCase: GetAppLanguageNameUseCase(
                        getAppLanguageNameRepositoryInterface: getLanguageNameInEnglishRepository
                    ),
                    getAppLanguageNameInAppLanguageUseCase: GetAppLanguageNameInAppLanguageUseCase(
                        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                            getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                            getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                            getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                        ),
                        getAppLanguageNameRepositoryInterface: getLanguageNameInEnglishRepository
                    ),
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                let searchAppLanguageUseCase = SearchAppLanguageInAppLanguagesListUseCase(
                    getAppLanguagesListUseCase: getAppLanguagesListUseCase
                )
                
                it("I should get languages that start with the character 'c' sorted in ascending order by language name translated in the current app language.") {
                    
                    waitUntil { done in
                        
                        var searchedLanguagesRef: [AppLanguageListItemDomainModel] = Array()
                        
                        _ = searchAppLanguageUseCase.getSearchResultsPublisher(for: Just("c").eraseToAnyPublisher())
                            .sink { (searchedAppLanguages: [AppLanguageListItemDomainModel]) in
                                
                                searchedLanguagesRef = searchedAppLanguages
                                
                                done()
                            }
                        
                        expect(searchedLanguagesRef[0].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Chinese"))
                        expect(searchedLanguagesRef[1].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Czech"))
                        expect(searchedLanguagesRef.count).to(equal(2))
                    }
                }
            }
        }
    }
}
