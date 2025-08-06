//
//  GetOnboardingTutorialIsAvailableTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools
import Combine

struct GetOnboardingTutorialIsAvailableTests {
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the first time and the onboarding tutorial has not been viewed.
        Then: The onboarding tutorial should be available.
        """
    )
    func onboardingTutorialIsAvailableOnFirstAppLaunch() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
            launchCountRepository: MockLaunchCountRepository(launchCount: 1),
            onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
        )
        
        var isAvailableRef: Bool?
                
        await confirmation(expectedCount: 1) { confirmation in
            
            getOnboardingIsAvailable
                .isAvailablePublisher()
                .sink { (isAvailable: Bool) in
                        
                    confirmation()

                    isAvailableRef = isAvailable
                }
                .store(in: &cancellables)
        }
        
        #expect(isAvailableRef == true)
    }
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the second time and the onboarding tutorial has been viewed.
        Then: The onboarding tutorial should not be available.
        """
    )
    func onboardingTutorialShouldNotBeAvailableOnSecondAppLaunchAndAlreadyViewed() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
            launchCountRepository: MockLaunchCountRepository(launchCount: 2),
            onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: true)
        )
        
        var isAvailableRef: Bool?
                
        await confirmation(expectedCount: 1) { confirmation in
            
            getOnboardingIsAvailable
                .isAvailablePublisher()
                .sink { (isAvailable: Bool) in
                        
                    confirmation()

                    isAvailableRef = isAvailable
                }
                .store(in: &cancellables)
        }
        
        #expect(isAvailableRef == false)
    }
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the second time and the onboarding tutorial has not been viewed.
        Then: The onboarding tutorial should not be available.
        """
    )
    func onboardingTutorialShouldNotBeAvailableOnSecondAppLaunchAndNotViewed() async {
        
        var cancellables: Set<AnyCancellable> = Set()
        
        let getOnboardingIsAvailable = GetOnboardingTutorialIsAvailable(
            launchCountRepository: MockLaunchCountRepository(launchCount: 2),
            onboardingTutorialViewedRepository: MockOnboardingTutorialViewedRepository(tutorialViewed: false)
        )
        
        var isAvailableRef: Bool?
                
        await confirmation(expectedCount: 1) { confirmation in
            
            getOnboardingIsAvailable
                .isAvailablePublisher()
                .sink { (isAvailable: Bool) in
                        
                    confirmation()

                    isAvailableRef = isAvailable
                }
                .store(in: &cancellables)
        }
        
        #expect(isAvailableRef == false)
    }
}
