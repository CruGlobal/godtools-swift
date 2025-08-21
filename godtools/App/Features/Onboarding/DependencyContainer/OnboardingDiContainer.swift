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
    let domainInterfaceLayer: OnboardingDomainInterfaceDependencies
    let domainLayer: OnboardingDomainLayerDependencies
    
    init(coreDataLayer: CoreDataLayerDependenciesInterface, dataLayer: OnboardingDataLayerDependenciesInterface, domainInterfaceLayer: OnboardingDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = OnboardingDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
