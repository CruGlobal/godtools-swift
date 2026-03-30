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
    let domainLayer: OnboardingDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, domainLayer: OnboardingDomainLayerDependencies) {
        
        self.dataLayer = OnboardingDataLayerDependencies(coreDataLayer: coreDataLayer)
        self.domainLayer = domainLayer
    }
}
