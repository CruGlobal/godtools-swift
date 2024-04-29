//
//  StoreInitialAppLanguageTests.swift
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

class StoreInitialAppLanguageTests: QuickSpec {
    
    override class func spec() {
        
        describe("App is launched.") {
            
            context("When no app language is currently set and my device language is english.") {
                
                let testsDiContainer = TestsDiContainer()
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage.getMockEnglishDevice(),
                    userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
                    appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository()
                )
                
                it("I expect my app language to be the device language english since english is a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    expect(resultRef).to(equal("en"))
                }
            }
            
            context("When no app language is currently set and my device language is arabic.") {
                
                let testsDiContainer = TestsDiContainer()
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "ar")),
                    userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
                    appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository()
                )
                
                it("I expect my app language to be the device language arabic since arabic is a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    expect(resultRef).to(equal("ar"))
                }
            }
            
            context("When my app language is set to spanish and my device language is arabic.") {
                
                let testsDiContainer = TestsDiContainer()
                
                let userAppLanguageRepository: UserAppLanguageRepository = testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository()
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "ar")),
                    userAppLanguageRepository: userAppLanguageRepository,
                    appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository()
                )
                
                it("I expect my app language to stay in spanish.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = userAppLanguageRepository
                            .storeLanguagePublisher(languageId: "es")
                            .flatMap({ (didStore: Bool) -> AnyPublisher<AppLanguageDomainModel, Never> in
                                
                                return storeInitialAppLanguage
                                    .storeInitialAppLanguagePublisher()
                                    .eraseToAnyPublisher()
                            })
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    expect(resultRef).to(equal("es"))
                }
            }
            
            context("When no app language is currently set and my device language is Czech.") {
                
                let testsDiContainer = TestsDiContainer()
                
                let storeInitialAppLanguage = StoreInitialAppLanguage(
                    deviceSystemLanguage: MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "cs")),
                    userAppLanguageRepository: testsDiContainer.feature.appLanguage.dataLayer.getUserAppLanguageRepository(),
                    appLanguagesRepository: testsDiContainer.feature.appLanguage.dataLayer.getAppLanguagesRepository()
                )
                
                it("I expect my app language to be english since Czech is not a supported app language.") {
                                        
                    var resultRef: AppLanguageDomainModel?
                    
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = storeInitialAppLanguage
                            .storeInitialAppLanguagePublisher()
                            .sink { (result: AppLanguageDomainModel) in
                            
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                resultRef = result
                                
                                sinkCompleted = true
                                
                                done()
                            }
                    }
                    
                    expect(resultRef).to(equal("en"))
                }
            }
        }
    }
}
