//
//  ShareGodToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class ShareGodToolsDiContainer {
    
    let dataLayer: ShareGodToolsDataLayerDependencies
    let domainLayer: ShareGodToolsDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = ShareGodToolsDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ShareGodToolsDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
