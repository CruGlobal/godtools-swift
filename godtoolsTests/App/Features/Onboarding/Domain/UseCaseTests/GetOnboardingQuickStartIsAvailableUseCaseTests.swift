//
//  GetOnboardingQuickStartIsAvailableUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetOnboardingQuickStartIsAvailableUseCaseTests: QuickSpec {
        
    override class func spec() {
        
        describe("User launches the app and is viewing the onboarding tutorial.") {
         
            context("When the app language is english.") {
                
                it("The onboarding quick start screen should be available.") {
                    
                    let getOnboardingQuickStartIsAvailableUseCase = GetOnboardingQuickStartIsAvailableUseCase(
                        getSupportedLanguagesRepositoryInterface: TestsGetOnboardingQuickStartSupportedLanguagesRepository(
                            supportedLanguages: [.english, .latvian, .spanish, .vietnamese]
                        )
                    )
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingQuickStartIsAvailableUseCase
                            .getAvailablePublisher(appLanguageCodeChangedPublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (isAvailable: Bool) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                isAvailableRef = isAvailable
                                
                                done()
                            }
                        
                    }

                    expect(isAvailableRef).to(equal(true))
                }
            }
            
            context("When the app language is french.") {
                
                it("The onboarding quick start screen should available.") {
                    
                    let getOnboardingQuickStartIsAvailableUseCase = GetOnboardingQuickStartIsAvailableUseCase(
                        getSupportedLanguagesRepositoryInterface: TestsGetOnboardingQuickStartSupportedLanguagesRepository(
                            supportedLanguages: [.arabic, .french]
                        )
                    )
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.french.value)
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingQuickStartIsAvailableUseCase
                            .getAvailablePublisher(appLanguageCodeChangedPublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (isAvailable: Bool) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                isAvailableRef = isAvailable
                                
                                done()
                            }
                        
                    }

                    expect(isAvailableRef).to(equal(true))
                }
            }
            
            context("When the app language is in arabic.") {
                
                it("The onboarding quick start screen should not be available.") {
                    
                    let getOnboardingQuickStartIsAvailableUseCase = GetOnboardingQuickStartIsAvailableUseCase(
                        getSupportedLanguagesRepositoryInterface: TestsGetOnboardingQuickStartSupportedLanguagesRepository(
                            supportedLanguages: [.english, .french, .latvian, .spanish, .vietnamese]
                        )
                    )
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.arabic.value)
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingQuickStartIsAvailableUseCase
                            .getAvailablePublisher(appLanguageCodeChangedPublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (isAvailable: Bool) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCompleted = true
                                
                                isAvailableRef = isAvailable
                                
                                done()
                            }
                        
                    }

                    expect(isAvailableRef).to(equal(false))
                }
            }
        }
    }
}
