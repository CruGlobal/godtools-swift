//
//  ToolShortcutLinksDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolShortcutLinksDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: ToolShortcutLinksDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: ToolShortcutLinksDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getToolShortcutLinksUseCase() -> GetToolShortcutLinksUseCase {
        return GetToolShortcutLinksUseCase(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
}
