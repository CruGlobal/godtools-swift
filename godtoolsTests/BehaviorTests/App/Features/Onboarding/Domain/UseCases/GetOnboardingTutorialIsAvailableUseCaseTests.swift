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
                
        let getOnboardingIsAvailable = await getOnboardingTutorialIsAvailableUseCase(
            launchCount: 1,
            tutorialViewed: false
        )
        
        let isAvailable: Bool = await getOnboardingIsAvailable.execute()
        
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
                
        let getOnboardingIsAvailable = await getOnboardingTutorialIsAvailableUseCase(
            launchCount: 2,
            tutorialViewed: true
        )
        
        let isAvailable: Bool = await getOnboardingIsAvailable.execute()
        
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
                
        let getOnboardingIsAvailable = await getOnboardingTutorialIsAvailableUseCase(
            launchCount: 2,
            tutorialViewed: false
        )
        
        let isAvailable: Bool = await getOnboardingIsAvailable.execute()
        
        #expect(isAvailable == false)
    }
}

extension GetOnboardingTutorialIsAvailableUseCaseTests {
    
    private func getOnboardingTutorialIsAvailableUseCase(launchCount: Int, tutorialViewed: Bool) async -> GetOnboardingTutorialIsAvailableUseCase {
        
        let cache = OnboardingTutorialViewedCache(userDefaultsCache: InMemUserDefaultsCache())
        
        await cache.storeOnboardingTutorialViewed(viewed: tutorialViewed)
        
        let getOnboardingTutorialIsAvailable = GetOnboardingTutorialIsAvailable(
            launchCountRepository: FakeLaunchCountRepository(launchCount: launchCount),
            onboardingTutorialViewedRepository: OnboardingTutorialViewedRepository(cache: cache)
        )
            
        return GetOnboardingTutorialIsAvailableUseCase(
            getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable
        )
    }
}
