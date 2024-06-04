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
    
    func getPersistUserToolSettingsIfFavoriteToolUseCase() -> PersistUserToolSettingsIfFavoriteToolUseCase {
        return PersistUserToolSettingsIfFavoriteToolUseCase(
            persistUserToolSettingsIfFavoriteToolRepositoryInterface: dataLayer.getPersistUserToolSettingsIfFavoriteToolRepositoryInterface()
        )
    }
    
    func getViewShareToolUseCase() -> ViewShareToolUseCase {
        return ViewShareToolUseCase(
            getInterfaceStringsRepository: dataLayer.getShareToolInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewToolSettingsToolLanguagesListUseCase() -> ViewToolSettingsToolLanguagesListUseCase {
        return ViewToolSettingsToolLanguagesListUseCase(
            getInterfaceStringsRepository: dataLayer.getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface(),
            getToolLanguagesRepository: dataLayer.getToolSettingsToolLanguagesListRepositoryInterface()
        )
    }
    
    func getViewToolSettingsUseCase() -> ViewToolSettingsUseCase {
        return ViewToolSettingsUseCase(
            getInterfaceStringsRepository: dataLayer.getToolSettingsInterfaceStringsRepositoryInterface(),
            getToolHasTipsRepository: dataLayer.getToolSettingsToolHasTipsRepositoryInterface(),
            getPrimaryLanguageRepository: dataLayer.getToolSettingsPrimaryLanguageRepositoryInterface(),
            getParallelLanguageRepository: dataLayer.getToolSettingsParallelLanguageRepositoryInterface()
        )
    }
}
