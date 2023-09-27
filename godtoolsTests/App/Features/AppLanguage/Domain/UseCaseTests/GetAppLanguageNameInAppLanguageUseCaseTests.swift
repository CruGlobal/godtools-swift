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
                    
                    let languageName: AppLanguageNameDomainModel = getAppLanguageNameUseCase.getLanguageName(languageCode: LanguageCodeDomainModel.russian.value)
                    
                    expect(languageName.value).to(equal("Russian"))
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
                    
                    let languageName: AppLanguageNameDomainModel = getAppLanguageNameUseCase.getLanguageName(languageCode: LanguageCodeDomainModel.czech.value)
                    
                    expect(languageName.value).to(equal("Czech"))
                }
            }
        }
    }
}
