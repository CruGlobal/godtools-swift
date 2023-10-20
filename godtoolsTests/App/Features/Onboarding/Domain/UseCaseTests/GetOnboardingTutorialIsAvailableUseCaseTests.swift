//
//  GetOnboardingTutorialIsAvailableUseCaseTests.swift
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

class GetOnboardingTutorialIsAvailableUseCaseTests: QuickSpec {
    
    override class func spec() {
        
        describe("User launches the app.") {
         
            context("When the app is launched for the first time and the onboarding tutorial has not been viewed.") {
                
                let getOnboardingTutorialIsAvailableUseCase = GetOnboardingTutorialIsAvailableUseCase(
                    getLaunchCountUseCase: GetLaunchCountUseCase(
                        getLaunchCountRepositoryInterface: TestsGetLaunchCountRepository(launchCount: 1)
                    ),
                    getViewedRepositoryInterface: TestsGetOnboardingTutorialViewedRepository(tutorialViewed: false)
                )
                
                it("The onboarding tutorial should be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingTutorialIsAvailableUseCase
                            .getAvailablePublisher()
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
                
                let getOnboardingTutorialIsAvailableUseCase = GetOnboardingTutorialIsAvailableUseCase(
                    getLaunchCountUseCase: GetLaunchCountUseCase(
                        getLaunchCountRepositoryInterface: TestsGetLaunchCountRepository(launchCount: 2)
                    ),
                    getViewedRepositoryInterface: TestsGetOnboardingTutorialViewedRepository(tutorialViewed: true)
                )
                
                it("The onboarding tutorial should not be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingTutorialIsAvailableUseCase
                            .getAvailablePublisher()
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
                
                let getOnboardingTutorialIsAvailableUseCase = GetOnboardingTutorialIsAvailableUseCase(
                    getLaunchCountUseCase: GetLaunchCountUseCase(
                        getLaunchCountRepositoryInterface: TestsGetLaunchCountRepository(launchCount: 2)
                    ),
                    getViewedRepositoryInterface: TestsGetOnboardingTutorialViewedRepository(tutorialViewed: false)
                )
                
                it("The onboarding tutorial should be available.") {
                    
                    var isAvailableRef: Bool?
                    var sinkCompleted: Bool = false
                    
                    waitUntil { done in
                          
                        _ = getOnboardingTutorialIsAvailableUseCase
                            .getAvailablePublisher()
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

