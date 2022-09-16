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
    
    func getAllFavoritedResourceModelsUseCase() -> GetAllFavoritedResourceModelsUseCase {
        return GetAllFavoritedResourceModelsUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getAllFavoritedToolsLatestTranslationFilesUseCase() -> GetAllFavoritedToolsLatestTranslationFilesUseCase {
        return GetAllFavoritedToolsLatestTranslationFilesUseCase(
            getAllFavoritedResourceModelsUseCase: getAllFavoritedResourceModelsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getAllFavoritedToolsUseCase() -> GetAllFavoritedToolsUseCase {
        return GetAllFavoritedToolsUseCase(
            getAllFavoritedResourceModelsUseCase: getAllFavoritedResourceModelsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getToolUseCase: getToolUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getAllToolsUseCase() -> GetAllToolsUseCase {
        return GetAllToolsUseCase(
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getToolUseCase: getToolUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getBannerImageUseCase() -> GetBannerImageUseCase {
        return GetBannerImageUseCase(attachmentsRepository: dataLayer.getAttachmentsRepository())
    }
    
    func getLessonUseCase() -> GetLessonUseCase {
        return GetLessonUseCase()
    }
    
    func getLessonsUseCase() -> GetLessonsUseCase {
        return GetLessonsUseCase(
            getLessonUseCase: getLessonUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase()
    }
    
    func getLanguageAvailabilityUseCase() -> GetLanguageAvailabilityUseCase {
        return GetLanguageAvailabilityUseCase(
            localizationServices: dataLayer.getLocalizationServices()
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
    
    func getSettingsLanguagesUseCase() -> GetSettingsLanguagesUseCase {
        return GetSettingsLanguagesUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getLanguageUseCase: getLanguageUseCase()
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
            getAllFavoritedResourceModelsUseCase: getAllFavoritedResourceModelsUseCase(),
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
    
    func getToolCategoriesUseCase() -> GetToolCategoriesUseCase {
        return GetToolCategoriesUseCase(
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            localizationServices: dataLayer.getLocalizationServices(),
            resourcesRepository: dataLayer.getResourcesRepository()
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
        return GetToolUseCase(
            getLanguageUseCase: getLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
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
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        return GetTutorialUseCase(
            localizationServices: dataLayer.getLocalizationServices(),
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getUserDidDeleteSettingsParallelLanguageUseCase() -> UserDidDeleteSettingsParallelLanguageUseCase {
        return UserDidDeleteSettingsParallelLanguageUseCase(
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
