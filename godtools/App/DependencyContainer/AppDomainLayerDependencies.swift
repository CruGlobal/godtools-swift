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
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getAllFavoritedToolsLatestTranslationFilesUseCase() -> GetAllFavoritedToolsLatestTranslationFilesUseCase {
        return GetAllFavoritedToolsLatestTranslationFilesUseCase(
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getAllFavoritedToolsUseCase() -> GetAllFavoritedToolsUseCase {
        return GetAllFavoritedToolsUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getAllToolsUseCase() -> GetAllToolsUseCase {
        return GetAllToolsUseCase(
            getToolUseCase: getToolUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getBannerImageUseCase() -> GetBannerImageUseCase {
        return GetBannerImageUseCase(attachmentsRepository: dataLayer.getAttachmentsRepository())
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
    
    func getShortcutItemsUseCase() -> GetShortcutItemsUseCase {
        return GetShortcutItemsUseCase(
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            getToolUseCase: getToolUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getStoreInitialFavoritedToolsUseCase() -> StoreInitialFavoritedToolsUseCase {
        return StoreInitialFavoritedToolsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            launchCountRepository: dataLayer.getLaunchCountRepository()
        )
    }
    
    func getToggleToolFavoritedUseCase() -> ToggleToolFavoritedUseCase {
        return ToggleToolFavoritedUseCase(
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase(),
            addToolToFavoritesUseCase: getAddToolToFavoritesUseCase(),
            removeToolFromFavoritesUseCase: getRemoveToolFromFavoritesUseCase()
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
    
    func getToolLanguagesUseCase() -> GetToolLanguagesUseCase {
        return GetToolLanguagesUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getToolUseCase() -> GetToolUseCase {
        return GetToolUseCase()
    }
    
    func getToolVersionsUseCase() -> GetToolVersionsUseCase {
        return GetToolVersionsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            localizationServices: dataLayer.getLocalizationServices(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            getToolLanguagesUseCase: getToolLanguagesUseCase()
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
