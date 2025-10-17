//
//  ToolSettingsDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 12/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ToolSettingsDomainLayerDependencies {
    
    private let domainInterfaceLayer: ToolSettingsDomainInterfaceDependencies
    
    init(domainInterfaceLayer: ToolSettingsDomainInterfaceDependencies) {
        
        self.domainInterfaceLayer = domainInterfaceLayer
    }
    
    func getViewToolSettingsToolLanguagesListUseCase() -> ViewToolSettingsToolLanguagesListUseCase {
        return ViewToolSettingsToolLanguagesListUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getToolSettingsToolLanguagesListInterfaceStringsRepositoryInterface(),
            getToolLanguagesRepository: domainInterfaceLayer.getToolSettingsToolLanguagesListRepositoryInterface()
        )
    }
    
    func getViewToolSettingsUseCase() -> ViewToolSettingsUseCase {
        return ViewToolSettingsUseCase(
            getInterfaceStringsRepository: domainInterfaceLayer.getToolSettingsInterfaceStringsRepositoryInterface(),
            getToolHasTipsRepository: domainInterfaceLayer.getToolSettingsToolHasTipsRepositoryInterface(),
            getPrimaryLanguageRepository: domainInterfaceLayer.getToolSettingsPrimaryLanguageRepositoryInterface(),
            getParallelLanguageRepository: domainInterfaceLayer.getToolSettingsParallelLanguageRepositoryInterface()
        )
    }
}
