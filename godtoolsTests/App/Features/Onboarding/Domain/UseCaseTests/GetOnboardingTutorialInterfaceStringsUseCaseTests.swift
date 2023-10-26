//
//  GetOnboardingTutorialInterfaceStringsUseCaseTests.swift
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

class GetOnboardingTutorialInterfaceStringsUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the onboarding tutorial.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                let getOnboardingTutorialInterfaceStringsUseCase = GetOnboardingTutorialInterfaceStringsUseCase(
                    getStringsRepositoryInterface: TestsGetOnboardingTutorialInterfaceStringsRepository()
                )
                
                it("The interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishInterfaceStringsRef: OnboardingTutorialInterfaceStringsDomainModel?
                    var spanishInterfaceStringsRef: OnboardingTutorialInterfaceStringsDomainModel?
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getOnboardingTutorialInterfaceStringsUseCase
                            .getStringsPublisher(appLanguageCodeChangedPublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (interfaceStrings: OnboardingTutorialInterfaceStringsDomainModel) in
                                
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

                    expect(englishInterfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("Choose Language"))
                    expect(englishInterfaceStringsRef?.beginTutorialButtonTitle).to(equal("Begin"))
                    
                    expect(spanishInterfaceStringsRef?.chooseAppLanguageButtonTitle).to(equal("Elige lengua"))
                    expect(spanishInterfaceStringsRef?.beginTutorialButtonTitle).to(equal("Comenzar"))
                }
            }
        }
    }
}
