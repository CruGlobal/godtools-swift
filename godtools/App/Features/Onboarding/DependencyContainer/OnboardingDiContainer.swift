//
//  OnboardingDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class OnboardingDiContainer {
        
    let dataLayer: OnboardingDataLayerDependencies
    let domainInterfaceLayer: OnboardingDomainInterfaceDependencies
    let domainLayer: OnboardingDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: OnboardingDataLayerDependencies, domainInterfaceLayer: OnboardingDomainInterfaceDependencies) {
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = domainInterfaceLayer
        domainLayer = OnboardingDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
