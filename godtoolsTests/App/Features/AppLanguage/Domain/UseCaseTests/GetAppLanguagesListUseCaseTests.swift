//
//  GetAppLanguagesListUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppLanguagesListUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the available app languages list.") {
         
            context("The app language is in English.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.spanish, .french, .english, .russian])
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
                
                it("The app languages list should be sorted by the language name translated in the app language.") {
                    
                    waitUntil { done in
                                                
                        var appLanguagesListRef: [AppLanguageListItemDomainModel] = Array()
                        
                        _ = getAppLanguagesListUseCase.getAppLanguagesListPublisher()
                            .sink { (appLanguages: [AppLanguageListItemDomainModel]) in
                                
                                appLanguagesListRef = appLanguages
                                
                                done()
                            }
                        
                        expect(appLanguagesListRef[0].languageNameTranslatedInCurrentAppLanguage.value).to(equal("English"))
                        expect(appLanguagesListRef[1].languageNameTranslatedInCurrentAppLanguage.value).to(equal("French"))
                        expect(appLanguagesListRef[2].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Russian"))
                        expect(appLanguagesListRef[3].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Spanish"))
                    }
                }
            }
        }
    }
}
