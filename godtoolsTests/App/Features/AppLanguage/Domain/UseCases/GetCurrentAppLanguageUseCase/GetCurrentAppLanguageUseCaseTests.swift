//
//  GetCurrentAppLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetCurrentAppLanguageUseCaseTests: QuickSpec {
        
    override class func spec() {
        
        describe("User is viewing the app in their app language.") {
                        
            context("The device language is in Spanish and the user's preferred app language is null.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesListRepositoryInterface: TestsGetAppLanguagesListRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: nil),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .spanish)
                )
                
                it("App language should default to Spanish since Spanish is an available app language.") {
                    
                    let appLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
                    
                    expect(appLanguage).to(equal(LanguageCodeDomainModel.spanish.value))
                }
            }
            
            context("The device language is in hebrew and the user's app language is null.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesListRepositoryInterface: TestsGetAppLanguagesListRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: nil),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .hebrew)
                )
                
                it("App language should default to English since Hebrew is not an available app language.") {
                    
                    let appLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
                    
                    expect(appLanguage).to(equal(LanguageCodeDomainModel.english.value))
                }
            }
            
            context("The device language is in French and the user's app language is Russian.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesListRepositoryInterface: TestsGetAppLanguagesListRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .russian),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .french)
                )
                
                it("App language should be Russian since it's the user's app language.") {
                    
                    let appLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
                    
                    expect(appLanguage).to(equal(LanguageCodeDomainModel.russian.value))
                }
            }
            
            context("The device language is in French and the user's app language is Russian and Russian is not an available app language.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesListRepositoryInterface: TestsGetAppLanguagesListRepository(appLanguagesCodes: [.english, .french, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .russian),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .french)
                )
                
                it("App language should be French since Russian is not an available app language and French is an available app language.") {
                    
                    let appLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
                    
                    expect(appLanguage).to(equal(LanguageCodeDomainModel.french.value))
                }
            }
            
            context("The device language is in French and the user's app language is Russian and Russian and French are not available app languages.") {
                
                let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase = GetCurrentAppLanguageUseCase(
                    getAppLanguagesListRepositoryInterface: TestsGetAppLanguagesListRepository(appLanguagesCodes: [.english, .spanish]),
                    getUserPreferredAppLanguageRepositoryInterface: TestsGetUserPreferredAppLanguageRepository(userAppLanguageCode: .russian),
                    getDeviceAppLanguageRepositoryInterface: TestsGetDeviceLanguageRepository(deviceLanguageCode: .french)
                )

                it("App language should be English since Russian and French are not available app languages.") {
                    
                    let appLanguage: AppLanguageCodeDomainModel = getCurrentAppLanguageUseCase.getAppLanguage()
                    
                    expect(appLanguage).to(equal(LanguageCodeDomainModel.english.value))
                }
            }
        }
    }
}
