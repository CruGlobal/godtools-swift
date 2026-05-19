//
//  ShareGodToolsDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 4/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class ShareGodToolsDiContainer {
    
    let dataLayer: ShareGodToolsDataLayerDependencies
    let domainLayer: ShareGodToolsDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ShareGodToolsDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ShareGodToolsDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
