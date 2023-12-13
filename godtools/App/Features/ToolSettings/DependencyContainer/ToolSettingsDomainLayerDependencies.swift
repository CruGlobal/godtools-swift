//
//  ToolSettingsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDomainLayerDependencies {
    
    private let dataLayer: ToolSettingsDataLayerDependencies
    
    init(dataLayer: ToolSettingsDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getViewToolSettingsToolLanguagesListUseCase() -> ViewToolSettingsToolLanguagesListUseCase {
        return ViewToolSettingsToolLanguagesListUseCase(
            getInterfaceStringsRepository: dataLayer.getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface(),
            getToolLanguagesRepository: dataLayer.getToolSettingsToolLanguagesRepositoryInterface()
        )
    }
    
    func getViewToolSettingsUseCase() -> ViewToolSettingsUseCase {
        return ViewToolSettingsUseCase(
            getInterfaceStringsRepository: dataLayer.getToolSettingsInterfaceStringsRepositoryInterface()
        )
    }
    
    func getStoreToolSettingsParallelLanguageUseCase() -> StoreToolSettingsParallelLanguageUseCase {
        return StoreToolSettingsParallelLanguageUseCase(
            storeParallelLanguageRepository: dataLayer.getStoreToolSettingsParallelLanguageRepositoryInterface()
        )
    }
    
    func getStoreToolSettingsPrimaryLanguageUseCase() -> StoreToolSettingsPrimaryLanguageUseCase {
        return StoreToolSettingsPrimaryLanguageUseCase(
            storePrimaryLanguageRepository: dataLayer.getStoreToolSettingsPrimaryLanguageRepositoryInterface()
        )
    }
}
