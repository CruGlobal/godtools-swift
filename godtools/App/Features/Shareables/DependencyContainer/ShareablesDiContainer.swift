//
//  ShareablesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareablesDiContainer {
    
    let dataLayer: ShareablesDataLayerDependencies
    let domainLayer: ShareablesDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = ShareablesDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ShareablesDomainLayerDependencies(dataLayer: dataLayer)
    }
}
