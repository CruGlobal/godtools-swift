//
//  GetAppLanguageUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetAppLanguageUseCaseTests: QuickSpec {
        
    override class func spec() {
        
        describe("User is viewing the app in their app language.") {
                        
            context("The device language is in Spanish and the user's preferred app language is null.") {
                
                let getAppLanguageUseCase = GetAppLanguageUseCase(
                    userAppLanguageRepository: TestsUserAppLanguageRepository(userAppLanguage: nil),
                    getDeviceLanguageUseCase: GetDeviceLanguageUseCase(getDeviceLanguage: TestsDeviceLanguage(deviceLanguageCode: .spanish)),
                    getAppLanguagesUseCase: GetAppLanguagesUseCase(getAppLanguagesRepository: TestsAppLanguagesRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]))
                )
                
                it("App language should default to Spanish since Spanish is an available app language.") {
                    
                    waitUntil { done in
                                        
                        var appLanguageRef: AppLanguageDomainModel?
                        
                        _ = getAppLanguageUseCase.getAppLanguagePublisher()
                            .sink { (appLanguage: AppLanguageDomainModel) in
                                
                                appLanguageRef = appLanguage
                                
                                done()
                            }
                        
                        expect(appLanguageRef?.languageCode).to(equal(LanguageCode.spanish.value))
                    }
                }
            }
            
            context("The device language is in hebrew and the user's app language is null.") {
                
                let getAppLanguageUseCase = GetAppLanguageUseCase(
                    userAppLanguageRepository: TestsUserAppLanguageRepository(userAppLanguage: nil),
                    getDeviceLanguageUseCase: GetDeviceLanguageUseCase(getDeviceLanguage: TestsDeviceLanguage(deviceLanguageCode: .hebrew)),
                    getAppLanguagesUseCase: GetAppLanguagesUseCase(getAppLanguagesRepository: TestsAppLanguagesRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]))
                )
                
                it("App language should default to English since Hebrew is not an available app language.") {
                    
                    waitUntil { done in
                                        
                        var appLanguageRef: AppLanguageDomainModel?
                        
                        _ = getAppLanguageUseCase.getAppLanguagePublisher()
                            .sink { (appLanguage: AppLanguageDomainModel) in
                                
                                appLanguageRef = appLanguage
                                
                                done()
                            }
                        
                        expect(appLanguageRef?.languageCode).to(equal(LanguageCode.english.value))
                    }
                }
            }
            
            context("The device language is in French and the user's app language is Russian.") {
                
                let getAppLanguageUseCase = GetAppLanguageUseCase(
                    userAppLanguageRepository: TestsUserAppLanguageRepository(userAppLanguage: AppLanguageDomainModel(direction: .leftToRight, languageCode: LanguageCode.russian.value)),
                    getDeviceLanguageUseCase: GetDeviceLanguageUseCase(getDeviceLanguage: TestsDeviceLanguage(deviceLanguageCode: .french)),
                    getAppLanguagesUseCase: GetAppLanguagesUseCase(getAppLanguagesRepository: TestsAppLanguagesRepository(appLanguagesCodes: [.english, .french, .russian, .spanish]))
                )
                
                it("App language should be Russian since it's the user's app language.") {
                    
                    waitUntil { done in
                                        
                        var appLanguageRef: AppLanguageDomainModel?
                        
                        _ = getAppLanguageUseCase.getAppLanguagePublisher()
                            .sink { (appLanguage: AppLanguageDomainModel) in
                                
                                appLanguageRef = appLanguage
                                
                                done()
                            }
                        
                        expect(appLanguageRef?.languageCode).to(equal(LanguageCode.russian.value))
                    }
                }
            }
            
            context("The device language is in French and the user's app language is Russian and Russian is not an available app language.") {
                
                let getAppLanguageUseCase = GetAppLanguageUseCase(
                    userAppLanguageRepository: TestsUserAppLanguageRepository(userAppLanguage: AppLanguageDomainModel(direction: .leftToRight, languageCode: LanguageCode.russian.value)),
                    getDeviceLanguageUseCase: GetDeviceLanguageUseCase(getDeviceLanguage: TestsDeviceLanguage(deviceLanguageCode: .french)),
                    getAppLanguagesUseCase: GetAppLanguagesUseCase(getAppLanguagesRepository: TestsAppLanguagesRepository(appLanguagesCodes: [.english, .french, .spanish]))
                )
                
                it("App language should be French since Russian is not an available app language and French is an available app language.") {
                    
                    waitUntil { done in
                                        
                        var appLanguageRef: AppLanguageDomainModel?
                        
                        _ = getAppLanguageUseCase.getAppLanguagePublisher()
                            .sink { (appLanguage: AppLanguageDomainModel) in
                                
                                appLanguageRef = appLanguage
                                
                                done()
                            }
                        
                        expect(appLanguageRef?.languageCode).to(equal(LanguageCode.french.value))
                    }
                }
            }
            
            context("The device language is in French and the user's app language is Russian and Russian and French are not available app languages.") {
                
                let getAppLanguageUseCase = GetAppLanguageUseCase(
                    userAppLanguageRepository: TestsUserAppLanguageRepository(userAppLanguage: AppLanguageDomainModel(direction: .leftToRight, languageCode: LanguageCode.russian.value)),
                    getDeviceLanguageUseCase: GetDeviceLanguageUseCase(getDeviceLanguage: TestsDeviceLanguage(deviceLanguageCode: .french)),
                    getAppLanguagesUseCase: GetAppLanguagesUseCase(getAppLanguagesRepository: TestsAppLanguagesRepository(appLanguagesCodes: [.english, .spanish]))
                )
                
                it("App language should be English since Russian and French are not available app languages.") {
                    
                    waitUntil { done in
                                        
                        var appLanguageRef: AppLanguageDomainModel?
                        
                        _ = getAppLanguageUseCase.getAppLanguagePublisher()
                            .sink { (appLanguage: AppLanguageDomainModel) in
                                
                                appLanguageRef = appLanguage
                                
                                done()
                            }
                        
                        expect(appLanguageRef?.languageCode).to(equal(LanguageCode.english.value))
                    }
                }
            }
        }
    }
}
