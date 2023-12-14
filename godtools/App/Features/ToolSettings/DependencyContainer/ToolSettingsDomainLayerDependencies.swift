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
    
    func getDeleteToolSettingsParallelLanguageUseCase() -> DeleteToolSettingsParallelLanguageUseCase {
        return DeleteToolSettingsParallelLanguageUseCase(
            deleteParallelLanguageRepository: dataLayer.getDeleteToolSettingsParallelLanguageRepositoryInterface()
        )
    }
    
    func getToolSettingsPrimaryLanguageUseCase() -> GetToolSettingsPrimaryLanguageUseCase {
        return GetToolSettingsPrimaryLanguageUseCase(
            getPrimaryLanguageRepository: dataLayer.getToolSettingsPrimaryLanguageRepositoryInterface()
        )
    }
    
    func getToolSettingsParallelLanguageUseCase() -> GetToolSettingsParallelLanguageUseCase {
        return GetToolSettingsParallelLanguageUseCase(
            getParallelLanguageRepository: dataLayer.getToolSettingsParallelLanguageRepositoryInterface()
        )
    }
    
    func getSetToolSettingsParallelLanguageUseCase() -> SetToolSettingsParallelLanguageUseCase {
        return SetToolSettingsParallelLanguageUseCase(
            storeParallelLanguageRepository: dataLayer.getStoreToolSettingsParallelLanguageRepositoryInterface()
        )
    }
    
    func getSetToolSettingsPrimaryLanguageUseCase() -> SetToolSettingsPrimaryLanguageUseCase {
        return SetToolSettingsPrimaryLanguageUseCase(
            storePrimaryLanguageRepository: dataLayer.getStoreToolSettingsPrimaryLanguageRepositoryInterface()
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
            getPrimaryLanguageRepository: dataLayer.getToolSettingsPrimaryLanguageRepositoryInterface(),
            getParallelLanguageRepository: dataLayer.getToolSettingsParallelLanguageRepositoryInterface()
        )
    }
}
