//
//  OnboardingDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDiContainer {
        
    let dataLayer: OnboardingDataLayerDependenciesInterface
    let businessLayer: OnboardingBusinessLayerDependencies
    let domainLayer: OnboardingDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: OnboardingDataLayerDependenciesInterface, businessLayer: OnboardingBusinessLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.businessLayer = businessLayer
        domainLayer = OnboardingDomainLayerDependencies(businessLayer: businessLayer)
    }
}
