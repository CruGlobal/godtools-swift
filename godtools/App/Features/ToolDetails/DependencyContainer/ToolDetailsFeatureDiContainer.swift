//
//  ToolDetailsFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolDetailsFeatureDiContainer {
    
    let dataLayer: ToolDetailsFeatureDataLayerDependencies
    let domainLayer: ToolDetailsFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, appLanguageFeatureDiContainer: AppLanguageFeatureDiContainer) {
        
        dataLayer = ToolDetailsFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolDetailsFeatureDomainLayerDependencies(dataLayer: dataLayer, appLanguageFeatureDiContainer: appLanguageFeatureDiContainer, coreDataLayer: coreDataLayer)
    }
}
