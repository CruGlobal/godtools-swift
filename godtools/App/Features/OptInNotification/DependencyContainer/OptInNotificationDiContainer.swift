//
//  OptInNotificationDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class OptInNotificationDiContainer {
        
    let dataLayer: OptInNotificationDataLayerDependencies
    let domainLayer: OptInNotificationDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailableInterface) {
        
        dataLayer = OptInNotificationDataLayerDependencies(coreDataLayer: coreDataLayer, getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable)
        
        domainLayer = OptInNotificationDomainLayerDependencies(dataLayer: dataLayer)
    }
}
