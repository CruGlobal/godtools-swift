//
//  SharablesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class SharablesDiContainer {
    
    let dataLayer: SharablesDataLayerDependencies
    let domainLayer: SharablesDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = SharablesDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = SharablesDomainLayerDependencies(dataLayer: dataLayer)
    }
}
