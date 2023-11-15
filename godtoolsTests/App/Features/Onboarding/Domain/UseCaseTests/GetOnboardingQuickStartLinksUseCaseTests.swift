//
//  GetOnboardingQuickStartLinksUseCaseTests.swift
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

class GetOnboardingQuickStartLinksUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User is viewing the onboarding quick start links.") {
         
            context("When the app language is switched from English to Spanish.") {
                
                let getOnboardingQuickStartLinksUseCase = GetOnboardingQuickStartLinksUseCase(
                    getLinksRepositoryInterface: TestsGetOnboardingQuickStartLinksRepository()
                )
                
                it("The quick start links interface strings should be translated into Spanish.") {
                    
                    let appLanguagePublisher: CurrentValueSubject<AppLanguageCodeDomainModel, Never> = CurrentValueSubject(LanguageCodeDomainModel.english.value)
                    
                    var englishLinksRef: [OnboardingQuickStartLinkDomainModel] = Array()
                    var spanishLinksRef: [OnboardingQuickStartLinkDomainModel] = Array()
                    
                    var sinkCount: Int = 0
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                        
                        _ = getOnboardingQuickStartLinksUseCase
                            .getLinksPublisher(appLanguagePublisher: appLanguagePublisher.eraseToAnyPublisher())
                            .sink { (links: [OnboardingQuickStartLinkDomainModel]) in
                                
                                guard !sinkCompleted else {
                                    return
                                }
                                
                                sinkCount += 1
                                
                                if sinkCount == 1 {
                                    
                                    englishLinksRef = links
                                }
                                else if sinkCount == 2 {
                                    
                                    spanishLinksRef = links
                                    
                                    sinkCompleted = true
                                    
                                    done()
                                }
                                                                
                                if sinkCount == 1 {
                                    appLanguagePublisher.send(LanguageCodeDomainModel.spanish.rawValue)
                                }
                            }
                    }

                    expect(englishLinksRef[0].title).to(equal("English Title"))
                    
                    expect(spanishLinksRef[0].title).to(equal("Título en inglés"))
                }
            }
        }
    }
}
