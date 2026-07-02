//
//  ShareablesDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 12/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ShareablesDiContainer {
    
    let dataLayer: ShareablesDataLayerDependencies
    let domainLayer: ShareablesDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ShareablesDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ShareablesDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
