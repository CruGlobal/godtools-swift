//
//  OnboardingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDomainLayerDependencies {
    
    private let dataLayer: OnboardingDataLayerDependencies
    
    init(dataLayer: OnboardingDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getOnboardingTutorialInterfaceStringsUseCase() -> GetOnboardingTutorialInterfaceStringsUseCase {
        return GetOnboardingTutorialInterfaceStringsUseCase(
            getStringsRepositoryInterface: dataLayer.getOnboardingTutorialInterfaceStringsRepositoryInterface()
        )
    }
    
    func getOnboardingTutorialIsAvailableUseCase() -> GetOnboardingTutorialIsAvailableUseCase {
        return GetOnboardingTutorialIsAvailableUseCase(
            onboardingTutorialIsAvailable: dataLayer.getOnboardingTutorialIsAvailable()
        )
    }
    
    func getTrackViewedOnboardingTutorialUseCase() -> TrackViewedOnboardingTutorialUseCase {
        return TrackViewedOnboardingTutorialUseCase(
            storeViewedRepositoryInterface: dataLayer.getStoreOnboardingTutorialViewedRepositoryInterface()
        )
    }
}
