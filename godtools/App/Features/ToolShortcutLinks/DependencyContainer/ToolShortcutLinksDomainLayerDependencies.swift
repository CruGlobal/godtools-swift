//
//  ToolShortcutLinksDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class ToolShortcutLinksDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: ToolShortcutLinksDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: ToolShortcutLinksDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getToolShortcutLinksUseCase() -> GetToolShortcutLinksUseCase {
        return GetToolShortcutLinksUseCase(
            favoritedResourcesRepository: core.dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: core.dataLayer.getResourcesRepository(),
            translationsRepository: core.dataLayer.getTranslationsRepository()
        )
    }
}
