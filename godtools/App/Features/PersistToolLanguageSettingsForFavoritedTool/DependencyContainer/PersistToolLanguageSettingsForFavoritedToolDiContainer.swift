//
//  PersistToolLanguageSettingsForFavoritedToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistToolLanguageSettingsForFavoritedToolDiContainer {
    
    let dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies
    let domainLayer: PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies) {
        
        dataLayer = PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies(coreDataLayer: coreDataLayer)
        domainLayer = PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies(coreDataLayer: coreDataLayer, dataLayer: dataLayer)
    }
}
