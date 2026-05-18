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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = AppLanguageDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = AppLanguageDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
