//
//  ToolShortcutLinksDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolShortcutLinksDomainLayerDependencies {
    
    private let dataLayer: ToolShortcutLinksDataLayerDependencies
    
    init(dataLayer: ToolShortcutLinksDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getToolShortcutLinksUseCase() -> GetToolShortcutLinksUseCase {
        return GetToolShortcutLinksUseCase(
            getToolShortcutLinksRepositoryInterface: dataLayer.getToolShortcutLinksRepositoryInterface()
        )
    }
}
