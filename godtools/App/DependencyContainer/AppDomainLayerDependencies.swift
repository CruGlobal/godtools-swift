//
//  AppDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDomainLayerDependencies {
    
    private let dataLayer: AppDataLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase()
    }
    
    func getLanguagesListUseCase() -> GetLanguagesListUseCase {
        return GetLanguagesListUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getLanguageUseCase() -> GetLanguageUseCase {
        return GetLanguageUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingQuickLinksEnabledUseCase() -> GetOnboardingQuickLinksEnabledUseCase {
        return GetOnboardingQuickLinksEnabledUseCase(
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getSettingsPrimaryLanguageUseCase() -> GetSettingsPrimaryLanguageUseCase {
        return GetSettingsPrimaryLanguageUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            languageSettingsRepository: dataLayer.getLanguageSettingsRepository(),
            getDeviceLanguageUseCase: getDeviceLanguageUseCase(),
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getSettingsParallelLanguageUseCase() -> GetSettingsParallelLanguageUseCase {
        return GetSettingsParallelLanguageUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            languageSettingsRepository: dataLayer.getLanguageSettingsRepository(),
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getToolTranslationsUseCase() -> GetToolTranslationsUseCase {
        return GetToolTranslationsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository(),
            languagesRepository: dataLayer.getLanguagesRepository()
        )
    }
    
    func getUserDidDeleteParallelLanguageUseCase() -> UserDidDeleteParallelLanguageUseCase {
        return UserDidDeleteParallelLanguageUseCase(
            languageSettingsRepository: dataLayer.getLanguageSettingsRepository()
        )
    }
    
    func getUserDidSetSettingsParallelLanguageUseCase() -> UserDidSetSettingsParallelLanguageUseCase {
        return UserDidSetSettingsParallelLanguageUseCase(
            languageSettingsRepository: dataLayer.getLanguageSettingsRepository()
        )
    }
    
    func getUserDidSetSettingsPrimaryLanguageUseCase() -> UserDidSetSettingsPrimaryLanguageUseCase {
        return UserDidSetSettingsPrimaryLanguageUseCase(
            languageSettingsRepository: dataLayer.getLanguageSettingsRepository()
        )
    }
}
