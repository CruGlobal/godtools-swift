//
//  ToolScreenShareQRCodeDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 6/13/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

final class ToolScreenShareQRCodeDiContainer {
    
    let dataLayer: ToolScreenShareQRCodeDataLayerDependencies
    let domainLayer: ToolScreenShareQRCodeDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, coreDomainLayer: AppDomainLayerDependencies) {
        
        dataLayer = ToolScreenShareQRCodeDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolScreenShareQRCodeDomainLayerDependencies(coreDataLayer: coreDataLayer, coreDomainLayer: coreDomainLayer, dataLayer: dataLayer)
    }
}
