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
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesRepositoryInterface: TestsGetAppLanguagesRepository(appLanguagesCodes: [.spanish, .french, .english, .russian]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                )
                
                let appLanguages: [AppLanguageListItemDomainModel] = [
                    AppLanguageListItemDomainModel(
                        languageCode: LanguageCodeDomainModel.spanish.value,
                        languageNameTranslatedInOwnLanguage: "",
                        languageNameTranslatedInCurrentAppLanguage: "Spanish"
                    ),
                    AppLanguageListItemDomainModel(
                        languageCode: LanguageCodeDomainModel.french.value,
                        languageNameTranslatedInOwnLanguage: "",
                        languageNameTranslatedInCurrentAppLanguage: "French"
                    ),
                    AppLanguageListItemDomainModel(
                        languageCode: LanguageCodeDomainModel.english.value,
                        languageNameTranslatedInOwnLanguage: "",
                        languageNameTranslatedInCurrentAppLanguage: "English"
                    ),
                    AppLanguageListItemDomainModel(
                        languageCode: LanguageCodeDomainModel.russian.value,
                        languageNameTranslatedInOwnLanguage: "",
                        languageNameTranslatedInCurrentAppLanguage: "Russian"
                    )
                ]
                
                let getAppLanguagesListRepositoryInterface = TestsGetAppLanguagesListRepository(appLanguages: appLanguages)
                
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                
                let getAppLanguagesListUseCase = GetAppLanguagesListUseCase(
                    getCurrentAppLanguageUseCase: getCurrentAppLanguageUseCase,
                    getAppLanguagesListRepositoryInterface: getAppLanguagesListRepositoryInterface,
                    getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository
                )
                
                it("The app languages list should be sorted by the language name translated in the app language.") {
                    
                    waitUntil { done in
                                                
                        var appLanguagesListRef: [AppLanguageListItemDomainModel] = Array()
                        var sinkCompleted: Bool = false
                        
                        _ = getAppLanguagesListUseCase.getAppLanguagesListPublisher()
                            .sink { (appLanguages: [AppLanguageListItemDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                appLanguagesListRef = appLanguages
                                
                                done()
                            }
                        
                        expect(appLanguagesListRef[0].languageNameTranslatedInCurrentAppLanguage).to(equal("English"))
                        expect(appLanguagesListRef[1].languageNameTranslatedInCurrentAppLanguage).to(equal("French"))
                        expect(appLanguagesListRef[2].languageNameTranslatedInCurrentAppLanguage).to(equal("Russian"))
                        expect(appLanguagesListRef[3].languageNameTranslatedInCurrentAppLanguage).to(equal("Spanish"))
                    }
                }
            }
        }
    }
}
