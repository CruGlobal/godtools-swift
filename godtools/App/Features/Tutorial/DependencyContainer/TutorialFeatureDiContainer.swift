//
//  TutorialFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class TutorialFeatureDiContainer {
    
    let dataLayer: TutorialFeatureDataLayerDependencies
    let domainLayer: TutorialFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = TutorialFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = TutorialFeatureDomainLayerDependencies(dataLayer: dataLayer)
    }
}
