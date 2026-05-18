//
//  OptInNotificationDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class OptInNotificationDiContainer {
        
    let dataLayer: OptInNotificationDataLayerDependencies
    let domainLayer: OptInNotificationDomainLayerDependencies
    
    init(core: AppCoreDiContainer, getOnboardingTutorialIsAvailable: GetOnboardingTutorialIsAvailable) {
        
        dataLayer = OptInNotificationDataLayerDependencies(coreDataLayer: core.dataLayer)
        
        domainLayer = OptInNotificationDomainLayerDependencies(core: core, dataLayer: dataLayer, getOnboardingTutorialIsAvailable: getOnboardingTutorialIsAvailable)
    }
}
