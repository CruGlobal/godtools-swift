//
//  OnboardingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDomainLayerDependencies {
    
    private let businessLayer: OnboardingBusinessLayerDependencies
    
    init(businessLayer: OnboardingBusinessLayerDependencies) {
        
        self.businessLayer = businessLayer
    }
    
    func getOnboardingTutorialInterfaceStringsUseCase() -> GetOnboardingTutorialInterfaceStringsUseCase {
        return GetOnboardingTutorialInterfaceStringsUseCase(
            stringsRepository: businessLayer.getOnboardingTutorialInterfaceStringsRepository()
        )
    }
    
    func getOnboardingTutorialIsAvailableUseCase() -> GetOnboardingTutorialIsAvailableUseCase {
        return GetOnboardingTutorialIsAvailableUseCase(
            onboardingTutorialIsAvailable: businessLayer.getOnboardingTutorialIsAvailable()
        )
    }
    
    func getTrackViewedOnboardingTutorialUseCase() -> TrackViewedOnboardingTutorialUseCase {
        return TrackViewedOnboardingTutorialUseCase(
            storeViewedRepository: businessLayer.getStoreOnboardingTutorialViewedRepository()
        )
    }
}
