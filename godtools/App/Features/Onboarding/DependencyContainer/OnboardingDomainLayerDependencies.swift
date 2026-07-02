//
//  OnboardingDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class OnboardingDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: OnboardingDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: OnboardingDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getOnboardingTutorialIsAvailable() -> GetOnboardingTutorialIsAvailable {
        return GetOnboardingTutorialIsAvailable(
            launchCountRepository: core.dataLayer.getLaunchCountRepository(),
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
            localizationServices: core.dataLayer.getLocalizationServices()
        )
    }
    
    func getViewedOnboardingTutorialUseCase() -> ViewedOnboardingTutorialUseCase {
        return ViewedOnboardingTutorialUseCase(
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
}
