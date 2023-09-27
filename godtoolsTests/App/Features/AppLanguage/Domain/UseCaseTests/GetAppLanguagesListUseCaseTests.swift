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
                    )
                )
                
                it("The app languages list should be sorted by the language name translated in the app language.") {
                    
                    let appLanguagesList: [AppLanguageListItemDomainModel] = getAppLanguagesListUseCase.getAppLanguagesList()
                    
                    expect(appLanguagesList[0].languageNameTranslatedInCurrentAppLanguage.value).to(equal("English"))
                    expect(appLanguagesList[1].languageNameTranslatedInCurrentAppLanguage.value).to(equal("French"))
                    expect(appLanguagesList[2].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Russian"))
                    expect(appLanguagesList[3].languageNameTranslatedInCurrentAppLanguage.value).to(equal("Spanish"))
                }
            }
        }
    }
}
