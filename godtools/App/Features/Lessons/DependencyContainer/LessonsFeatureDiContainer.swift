//
//  LessonsFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class LessonsFeatureDiContainer {
        
    let dataLayer: LessonsFeatureDataLayerDependencies
    let domainLayer: LessonsFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainlayer: AppDomainLayerDependencies, personalizedToolsDataLayer: PersonalizedToolsDataLayerDependencies) {
        
        dataLayer = LessonsFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = LessonsFeatureDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer, coreDomainlayer: coreDomainlayer, personalizedToolsDataLayer: personalizedToolsDataLayer)
    }
}
