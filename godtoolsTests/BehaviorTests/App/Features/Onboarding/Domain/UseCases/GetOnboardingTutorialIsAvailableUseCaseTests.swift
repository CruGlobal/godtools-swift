//
//  GetOnboardingTutorialIsAvailableUseCaseTests.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 3/14/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Testing
@testable import godtools

struct GetOnboardingTutorialIsAvailableUseCaseTests {
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the first time and the onboarding tutorial has not been viewed.
        Then: The onboarding tutorial should be available.
        """
    )
    func onboardingTutorialIsAvailableOnFirstAppLaunch() async {
                
        let getOnboardingIsAvailable = getOnboardingTutorialIsAvailableUseCase(
            launchCount: 1,
            tutorialViewed: false
        )
        
        let isAvailable: Bool = getOnboardingIsAvailable.execute()
        
        #expect(isAvailable == true)
    }
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the second time and the onboarding tutorial has been viewed.
        Then: The onboarding tutorial should not be available.
        """
    )
    func onboardingTutorialShouldNotBeAvailableOnSecondAppLaunchAndAlreadyViewed() async {
                
        let getOnboardingIsAvailable = getOnboardingTutorialIsAvailableUseCase(
            launchCount: 2,
            tutorialViewed: true
        )
        
        let isAvailable: Bool = getOnboardingIsAvailable.execute()
        
        #expect(isAvailable == false)
    }
    
    @Test(
        """
        Given: User launches the app.
        When: The app is launched for the second time and the onboarding tutorial has not been viewed.
        Then: The onboarding tutorial should not be available.
        """
    )
    func onboardingTutorialShouldNotBeAvailableOnSecondAppLaunchAndNotViewed() async {
                
        let getOnboardingIsAvailable = getOnboardingTutorialIsAvailableUseCase(
            launchCount: 2,
            tutorialViewed: false
        )
        
        let isAvailable: Bool = getOnboardingIsAvailable.execute()
        
        #expect(isAvailable == false)
    }
}

extension GetOnboardingTutorialIsAvailableUseCaseTests {
    
    private func getOnboardingTutorialIsAvailableUseCase(launchCount: Int, tutorialViewed: Bool) -> GetOnboardingTutorialIsAvailableUseCase {
        
        let cache = OnboardingTutorialViewedCache(userDefaultsCache: InMemUserDefaultsCache())
        
        cache.storeOnboardingTutorialViewed(viewed: tutorialViewed)
        
        let getOnboardingTutorialIsAvailable = GetOnboardingTutorialIsAvailable(
            launchCountRepository: MockLaunchCountRepository(launchCount: launchCount),
            onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository(cache: cache)
        )
            
        return GetOnboardingTutorialIsAvailableUseCase(
            getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable
        )
    }
}
