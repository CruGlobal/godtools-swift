//
//  GetOnboardingTutorialIsAvailableTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine
import Quick
import Nimble

class GetOnboardingTutorialIsAvailableTests: QuickSpec {
    
    override class func spec() {
        
        describe("User launches the app.") {
         
            context("When the app is launched for the first time and the onboarding tutorial has not been viewed.") {
                
                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
                    launchCountRepository: MockLaunchCountRepository(launchCount: 1),
                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
                )
                
                it("The onboarding tutorial should be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingIsAvailable
                            .isAvailablePublisher()
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
            
            context("When the app is launched for the second time and the onboarding tutorial has been viewed.") {
                
                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
                    launchCountRepository: MockLaunchCountRepository(launchCount: 2),
                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: true)
                )
                
                it("The onboarding tutorial should not be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingIsAvailable
                            .isAvailablePublisher()
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
            
            context("When the app is launched for the second time and the onboarding tutorial has not been viewed.") {
                
                let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
                    launchCountRepository: MockLaunchCountRepository(launchCount: 2),
                    onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
                )
                
                it("The onboarding tutorial should be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingIsAvailable
                            .isAvailablePublisher()
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
