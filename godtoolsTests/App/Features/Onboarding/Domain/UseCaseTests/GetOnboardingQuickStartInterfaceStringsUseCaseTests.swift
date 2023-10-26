//
//  GetOnboardingQuickStartInterfaceStringsUseCase.swift
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

class GetOnboardingQuickStartInterfaceStringsUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the onboarding quick start links.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                let getOnboardingQuickStartInterfaceStringsUseCase = GetOnboardingQuickStartInterfaceStringsUseCase(
                    getStringsRepositoryInterface: TestsGetOnboardingQuickStartInterfaceStringsRepository()
                )
                
                it("The interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: OnboardingQuickStartInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: OnboardingQuickStartInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getOnboardingQuickStartInterfaceStringsUseCase
                            .getStringsPublisher(appLanguageCodeChangedPublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (interfaceStrings: OnboardingQuickStartInterfaceStringsDomainModel) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    englishInterfaceStringsRef = interfaceStrings
                                }
                                else if sinkCount == 2 {
                                    
                                    spanishInterfaceStringsRef = interfaceStrings
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                                
                                if sinkCount == 1 {
                                    appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                                }
                            }
                    }

                    expect(englishInterfaceStringsRef?.title).to(equal("Quick Start Links"))
                    expect(englishInterfaceStringsRef?.getStartedButtonTitle).to(equal("Get Started"))
                    
                    expect(spanishInterfaceStringsRef?.title).to(equal("Enlaces de inicio rápido"))
                    expect(spanishInterfaceStringsRef?.getStartedButtonTitle).to(equal("Empezar"))
                }
            }
        }
    }
}

