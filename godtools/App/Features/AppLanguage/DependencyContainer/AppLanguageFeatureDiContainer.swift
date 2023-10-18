//
//  AppLanguageFeatureDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class AppLanguageFeatureDiContainer {
    
    let dataLayer: AppLanguageFeatureDataLayerDependencies
    let domainLayer: AppLanguageFeatureDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = AppLanguageFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AppLanguageFeatureDomainLayerDependencies(dataLayer: dataLayer, coreDataLayer: coreDataLayer)
    }
}
