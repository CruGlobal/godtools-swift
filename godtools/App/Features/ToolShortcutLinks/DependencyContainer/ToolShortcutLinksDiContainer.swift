//
//  ToolShortcutLinksDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolShortcutLinksDiContainer {
    
    let dataLayer: ToolShortcutLinksDataLayerDependencies
    let domainLayer: ToolShortcutLinksDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = ToolShortcutLinksDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = ToolShortcutLinksDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
