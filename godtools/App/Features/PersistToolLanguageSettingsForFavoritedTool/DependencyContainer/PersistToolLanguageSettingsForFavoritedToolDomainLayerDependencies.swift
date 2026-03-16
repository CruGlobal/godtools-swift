//
//  PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies {
    
    private let coreDataLayer: AppDataLayerDependencies
    private let dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies
    
    init(coreDataLayer: AppDataLayerDependencies, dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies) {
        
        self.coreDataLayer = coreDataLayer
        self.dataLayer = dataLayer
    }
    
    func getPersistToolLanguageSettingsForFavoritedToolUseCase() -> PersistToolLanguageSettingsForFavoritedToolUseCase {
        return PersistToolLanguageSettingsForFavoritedToolUseCase(
            userToolSettingsRepository: dataLayer.getUserToolSettingsRepository()
        )
    }
}
