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
    private let appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies
    
    init(dataLayer: OnboardingDataLayerDependencies, appLanguageFeatureDomainLayer: AppLanguageFeatureDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.appLanguageFeatureDomainLayer = appLanguageFeatureDomainLayer
    }
    
    func getOnboardingQuickLinksAvailableUseCase() -> GetOnboardingQuickLinksAvailableUseCase {
        return GetOnboardingQuickLinksAvailableUseCase()
    }
    
    func getOnboardingTutorialInterfaceStringsUseCase() -> GetOnboardingTutorialInterfaceStringsUseCase {
        
        return GetOnboardingTutorialInterfaceStringsUseCase(
            getStringsRepositoryInterface: dataLayer.getOnboardingTutorialInterfaceStringsRepositoryInterface()
        )
    }
}
