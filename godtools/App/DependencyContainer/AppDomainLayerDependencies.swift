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
    
    func getAddToolToFavoritesUseCase() -> AddToolToFavoritesUseCase {
        return AddToolToFavoritesUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            getFavoritedToolsLatestTranslationFilesUseCase: getFavoritedToolsLatestTranslationFilesUseCase()
        )
    }
    
    func getAllFavoritedToolsLatestTranslationFilesUseCase() -> GetAllFavoritedToolsLatestTranslationFilesUseCase {
        return GetAllFavoritedToolsLatestTranslationFilesUseCase(
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase(),
            getFavoritedToolsLatestTranslationFilesUseCase: getFavoritedToolsLatestTranslationFilesUseCase()
        )
    }
    
    func getAllFavoritedToolsUseCase() -> GetAllFavoritedToolsUseCase {
        return GetAllFavoritedToolsUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase()
    }
    
    func getFavoritedToolsLatestTranslationFilesUseCase() -> GetFavoritedToolsLatestTranslationFilesUseCase {
        return GetFavoritedToolsLatestTranslationFilesUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
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
    
    func getRemoveToolFromFavoritesUseCase() -> RemoveToolFromFavoritesUseCase {
        return RemoveToolFromFavoritesUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
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
    
    func getToolDetailsMediaUseCase() -> GetToolDetailsMediaUseCase {
        return GetToolDetailsMediaUseCase(
            attachmentsRepository: dataLayer.getAttachmentsRepository()
        )
    }
    
    func getToolIsFavoritedUseCase() -> GetToolIsFavoritedUseCase {
        return GetToolIsFavoritedUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getToolTranslationsFilesUseCase() -> GetToolTranslationsFilesUseCase {
        return GetToolTranslationsFilesUseCase(
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
