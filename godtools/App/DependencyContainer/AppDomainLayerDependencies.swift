//
//  AppDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDomainLayerDependencies {
    
    private static var backgroundDownloadingUseCase: BackgroundDownloadingUseCase!
    
    private let dataLayer: AppDataLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        
        AppDomainLayerDependencies.backgroundDownloadingUseCase = getBackgroundDownloadingUseCase()
    }
    
    func getAddToolToFavoritesUseCase() -> AddToolToFavoritesUseCase {
        return AddToolToFavoritesUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    private func getAllFavoritedToolsLatestTranslationFilesUseCase() -> GetAllFavoritedToolsLatestTranslationFilesUseCase {
        return GetAllFavoritedToolsLatestTranslationFilesUseCase(
            getAllFavoritedToolIDsUseCase: getAllFavoritedToolIDsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getAllFavoritedToolIDsUseCase() -> GetAllFavoritedToolIDsUseCase {
        return GetAllFavoritedToolIDsUseCase(favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository())
    }
    
    func getAllFavoritedToolsUseCase() -> GetAllFavoritedToolsUseCase {
        return GetAllFavoritedToolsUseCase(
            getAllFavoritedToolIDsUseCase: getAllFavoritedToolIDsUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    private func getBackgroundDownloadingUseCase() -> BackgroundDownloadingUseCase {
        return BackgroundDownloadingUseCase(
            getAllFavoritedToolsLatestTranslationFilesUseCase: getAllFavoritedToolsLatestTranslationFilesUseCase()
        )
    }
    
    func getBannerImageUseCase() -> GetBannerImageUseCase {
        return GetBannerImageUseCase(attachmentsRepository: dataLayer.getAttachmentsRepository())
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase()
    }
    
    func getFavoritedResourcesChangedUseCase() -> GetFavoritedResourcesChangedUseCase {
        return GetFavoritedResourcesChangedUseCase(favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository())
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
