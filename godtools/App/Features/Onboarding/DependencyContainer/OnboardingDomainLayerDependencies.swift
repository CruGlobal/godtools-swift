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
    private let appDomainLayer: AppDomainLayerDependencies
    private let appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies
    
    init(dataLayer: OnboardingDataLayerDependencies, appDomainLayer: AppDomainLayerDependencies, appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.appDomainLayer = appDomainLayer
        self.appLanguageFeatureDomainLayer = appLanguageFeatureDomainLayer
    }
    
    func getOnboardingTutorialInterfaceStringsUseCase() -> GetOnboardingTutorialInterfaceStringsUseCase {
        return GetOnboardingTutorialInterfaceStringsUseCase(
            getStringsRepositoryInterface: dataLayer.getOnboardingTutorialInterfaceStringsRepositoryInterface()
        )
    }
    
    func getOnboardingTutorialIsAvailableUseCase() -> GetOnboardingTutorialIsAvailableUseCase {
        return GetOnboardingTutorialIsAvailableUseCase(
            getLaunchCountUseCase: appDomainLayer.getLaunchCountUseCase(),
            getViewedRepositoryInterface: dataLayer.getOnboardingTutorialViewedRepositoryInterface()
        )
    }
    
    func getTrackViewedOnboardingTutorialUseCase() -> TrackViewedOnboardingTutorialUseCase {
        return TrackViewedOnboardingTutorialUseCase(
            storeViewedRepositoryInterface: dataLayer.getStoreOnboardingTutorialViewedRepositoryInterface()
        )
    }
}
