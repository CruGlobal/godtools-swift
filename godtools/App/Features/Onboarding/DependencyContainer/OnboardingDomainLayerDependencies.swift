//
//  OnboardingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDomainLayerDependencies {
    
    private let domainInterfaceLayer: OnboardingDomainInterfaceDependencies
    
    init(domainInterfaceLayer: OnboardingDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
    
    func getOnboardingTutorialInterfaceStringsUseCase() -> GetOnboardingTutorialInterfaceStringsUseCase {
        return GetOnboardingTutorialInterfaceStringsUseCase(
            stringsRepository: domainInterfaceLayer.getOnboardingTutorialInterfaceStringsRepository()
        )
    }
    
    func getOnboardingTutorialIsAvailableUseCase() -> GetOnboardingTutorialIsAvailableUseCase {
        return GetOnboardingTutorialIsAvailableUseCase(
            onboardingTutorialIsAvailable: domainInterfaceLayer.getOnboardingTutorialIsAvailable()
        )
    }
    
    func getTrackViewedOnboardingTutorialUseCase() -> TrackViewedOnboardingTutorialUseCase {
        return TrackViewedOnboardingTutorialUseCase(
            storeViewedRepository: domainInterfaceLayer.getStoreOnboardingTutorialViewedRepository()
        )
    }
}
