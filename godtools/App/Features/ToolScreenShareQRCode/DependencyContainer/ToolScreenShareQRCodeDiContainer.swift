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
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ToolScreenShareQRCodeDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ToolScreenShareQRCodeDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
