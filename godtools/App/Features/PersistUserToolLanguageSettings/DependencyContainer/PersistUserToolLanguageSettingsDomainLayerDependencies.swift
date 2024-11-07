//
//  PersistUserToolLanguageSettingsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

class PersistUserToolLanguageSettingsDomainLayerDependencies {
    
    private let dataLayer: PersistUserToolLanguageSettingsDataLayerDependencies
    
    init(dataLayer: PersistUserToolLanguageSettingsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getPersistUserToolLanguageSettingsUseCase() -> PersistUserToolLanguageSettingsUseCase {
        return PersistUserToolLanguageSettingsUseCase(
            persistUserToolLanguageSettingsRepositoryInterface: dataLayer.getPersistUserToolLanguageSettingsRepositoryInterface()
        )
    }
}
