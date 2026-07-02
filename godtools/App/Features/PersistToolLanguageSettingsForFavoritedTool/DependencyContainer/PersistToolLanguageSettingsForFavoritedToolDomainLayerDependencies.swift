//
//  PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class PersistToolLanguageSettingsForFavoritedToolDomainLayerDependencies {
    
    private let core: AppCoreDiContainer
    private let dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies
    
    init(core: AppCoreDiContainer, dataLayer: PersistToolLanguageSettingsForFavoritedToolDataLayerDependencies) {
        
        self.core = core
        self.dataLayer = dataLayer
    }
    
    func getPersistToolLanguageSettingsForFavoritedToolUseCase() -> PersistToolLanguageSettingsForFavoritedToolUseCase {
        return PersistToolLanguageSettingsForFavoritedToolUseCase(
            userToolSettingsRepository: dataLayer.getUserToolSettingsRepository()
        )
    }
}
