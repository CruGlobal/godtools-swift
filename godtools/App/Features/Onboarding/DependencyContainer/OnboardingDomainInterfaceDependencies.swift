//
//  OnboardingDomainInterfaceDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OnboardingDomainInterfaceDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: OnboardingDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: OnboardingDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getOnboardingTutorialInterfaceStringsRepository() -> GetOnboardingTutorialInterfaceStringsRepositoryInterface {
        return GetOnboardingTutorialInterfaceStringsRepository(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingTutorialIsAvailable() -> GetOnboardingTutorialIsAvailableInterface {
        return GetOnboardingTutorialIsAvailable(
            launchCountRepository: coreDataLayer.getLaunchCountRepository(),
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
    
    func getStoreOnboardingTutorialViewedRepository() -> StoreOnboardingTutorialViewedRepositoryInterface {
        return StoreOnboardingTutorialViewedRepository(
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
}
