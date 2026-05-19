//
//  OnboardingDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class OnboardingDiContainer {
        
    let dataLayer: OnboardingDataLayerDependencies
    let domainLayer: OnboardingDomainLayerDependencies
    
    init(dataLayer: OnboardingDataLayerDependencies, domainLayer: OnboardingDomainLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
