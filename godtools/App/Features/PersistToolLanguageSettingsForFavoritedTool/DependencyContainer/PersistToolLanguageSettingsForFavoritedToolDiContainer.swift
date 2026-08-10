//
//  PersistToolLanguageSettingsForFavoritedToolDiContainer.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

@MainActor
final class PersistToolLanguageSettingsForFavoritedToolDiContainer {
    
    let dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies
    let domainLayer: PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies
    
    init(dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies, domainLayer: PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies) {

        self.dataLayer = dataLayer
        self.domainLayer = domainLayer
    }
}
