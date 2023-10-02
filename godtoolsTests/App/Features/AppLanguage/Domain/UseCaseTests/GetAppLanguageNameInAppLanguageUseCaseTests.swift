//
//  GetAppLanguageNameInAppLanguageUseCaseTests.swift
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

class GetAppLanguageNameInAppLanguageUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the app languages list.") {
         
            context("When viewing the russian language name in the English app language.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.czech, .english, .russian, .spanish])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                
                let getAppLanguageNameUseCase = GetAppLanguageNameInAppLanguageUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepository(localeLanguageName: LocaleLanguageName())
                )
                
                it("The language name for Russian should be translated in the English language.") {
                    
                    waitUntil { done in
                        
                        var languageNameRef: AppLanguageNameDomainModel?
                        
                        _ = getAppLanguageNameUseCase.getLanguageNamePublisher(language: LanguageCodeDomainModel.russian.value)
                            .sink { (appLanguageName: AppLanguageNameDomainModel) in
                                
                                languageNameRef = appLanguageName
                                
                                done()
                            }
                        
                        expect(languageNameRef?.value).to(equal("Russian"))
                    }
                }
            }
            
            context("When viewing the Czech language name in the English app language.") {
                
                let getAppLanguagesListRepository = TestsGetAppLanguagesListRepository(appLanguagesCodes: [.czech, .english, .russian, .spanish])
                let getUserPreferredAppLanguageRepository = TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .english)
                let getDeviceAppLanguageRepository = TestsGetDeviceLanguageRepository(deviceLanguageCode: .english)
                
                let getAppLanguageNameUseCase = GetAppLanguageNameInAppLanguageUseCase(
                    getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase(
                        getAppLanguagesListRepositoryInterface: getAppLanguagesListRepository,
                        getUserPreferredAppLanguageRepositoryInterface: getUserPreferredAppLanguageRepository,
                        getDeviceAppLanguageRepositoryInterface: getDeviceAppLanguageRepository
                    ),
                    getAppLanguageNameRepositoryInterface: GetAppLanguageNameRepository(localeLanguageName: LocaleLanguageName())
                )
                
                it("The language name for Czech should be translated in the English language.") {
                    
                    waitUntil { done in
                        
                        var languageNameRef: AppLanguageNameDomainModel?
                        
                        _ = getAppLanguageNameUseCase.getLanguageNamePublisher(language: LanguageCodeDomainModel.czech.value)
                            .sink { (appLanguageName: AppLanguageNameDomainModel) in
                                
                                languageNameRef = appLanguageName
                                
                                done()
                            }
                        
                        expect(languageNameRef?.value).to(equal("Czech"))
                    }
                }
            }
        }
    }
}
