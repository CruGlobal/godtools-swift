//
//  ToolShortcutLinksDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolShortcutLinksDataLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
    }
    
    // MARK: - Data Layer Classes
    
    // MARK: - Domain Interface
    
    func getToolShortcutLinksRepositoryInterface() -> GetToolShortcutLinksRepositoryInterface {
        return GetToolShortcutLinksRepository(
            favoritedResourcesRepository: coreDataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: coreDataLayer.getResourcesRepository(),
            translationsRepository: coreDataLayer.getTranslationsRepository()
        )
    }
}
