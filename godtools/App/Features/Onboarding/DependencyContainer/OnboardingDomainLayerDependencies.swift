//
//  OnboardingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: OnboardingDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: OnboardingDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getOnboardingTutorialIsAvailable() -> GetOnboardingTutorialIsAvailable {
        return GetOnboardingTutorialIsAvailable(
            launchCountRepository: coreDataLayer.getLaunchCountRepository(),
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
    
    func getOnboardingTutorialIsAvailableUseCase() -> GetOnboardingTutorialIsAvailableUseCase {
        return GetOnboardingTutorialIsAvailableUseCase(
            getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable()
        )
    }
    
    func getOnboardingTutorialStringsUseCase() -> GetOnboardingTutorialStringsUseCase {
        return GetOnboardingTutorialStringsUseCase(
            localizationServices: coreDataLayer.getLocalizationServices()
        )
    }
    
    func getViewedOnboardingTutorialUseCase() -> ViewedOnboardingTutorialUseCase {
        return ViewedOnboardingTutorialUseCase(
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
}
