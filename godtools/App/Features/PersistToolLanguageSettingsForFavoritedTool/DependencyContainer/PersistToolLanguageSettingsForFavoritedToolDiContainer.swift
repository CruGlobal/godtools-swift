//
//  PersistToolLanguageSettingsForFavoritedToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class PersistToolLanguageSettingsForFavoritedToolDiContainer {
    
    let dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies
    let domainLayer: PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies
    
    init(core: AppCoreDiContainer) {
        
        dataLayer = PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies(coreDataLayer: core.dataLayer)
        domainLayer = PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies(core: core, dataLayer: dataLayer)
    }
}
