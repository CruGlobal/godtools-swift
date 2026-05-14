//
//  AppLanguageDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class AppLanguageDiContainer {
    
    let dataLayer: AppLanguageDataLayerDependencies
    let domainLayer: AppLanguageDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = AppLanguageDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = AppLanguageDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
