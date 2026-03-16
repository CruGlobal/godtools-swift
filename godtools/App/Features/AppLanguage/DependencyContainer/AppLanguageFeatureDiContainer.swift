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
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = AppLanguageFeatureDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AppLanguageFeatureDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
