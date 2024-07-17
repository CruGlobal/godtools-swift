//
//  ToolShortcutLinksDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolShortcutLinksDiContainer {
    
    let dataLayer: ToolShortcutLinksDataLayerDependencies
    let domainLayer: ToolShortcutLinksDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = ToolShortcutLinksDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = ToolShortcutLinksDomainLayerDependencies(dataLayer: dataLayer)
    }
}
