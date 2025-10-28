//
//  ShareToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 10/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

class ShareToolDiContainer {
        
    private let dataLayer: ShareToolDataLayerDependencies
    private let domainInterfaceLayer: ShareToolDomainInterfaceDependencies
    
    let domainLayer: ShareToolDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        let dataLayer = ShareToolDataLayerDependencies(coreDataLayer: coreDataLayer)
        
        self.dataLayer = dataLayer
        self.domainInterfaceLayer = ShareToolDomainInterfaceDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
        domainLayer = ShareToolDomainLayerDependencies(domainInterfaceLayer: domainInterfaceLayer)
    }
}
