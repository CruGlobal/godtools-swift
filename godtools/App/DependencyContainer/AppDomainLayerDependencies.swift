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
    
    func getAccountCreationIsSupportedUseCase() -> GetAccountCreationIsSupportedUseCase {
        return GetAccountCreationIsSupportedUseCase(
            appBuild: dataLayer.getAppBuild(),
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getAddToolToFavoritesUseCase() -> AddToolToFavoritesUseCase {
        return AddToolToFavoritesUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getAllFavoritedToolsLatestTranslationFilesUseCase() -> GetAllFavoritedToolsLatestTranslationFilesUseCase {
        return GetAllFavoritedToolsLatestTranslationFilesUseCase(
            getLanguageUseCase: getLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getAllFavoritedToolsUseCase() -> GetAllFavoritedToolsUseCase {
        return GetAllFavoritedToolsUseCase(
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getToolUseCase: getToolUseCase(),
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getAllToolsUseCase() -> GetAllToolsUseCase {
        return GetAllToolsUseCase(
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getToolUseCase: getToolUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            cruOktaAuthentication: dataLayer.getCruOktaAuthentication(),
            emailSignUpService: dataLayer.getEmailSignUpService(),
            firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics,
            snowplowAnalytics: dataLayer.getAnalytics().snowplowAnalytics
        )
    }
    
    func getBannerImageUseCase() -> GetBannerImageUseCase {
        return GetBannerImageUseCase(attachmentsRepository: dataLayer.getAttachmentsRepository())
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase(
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        return GetFeaturedLessonsUseCase(
            getLessonUseCase: getLessonUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getGlobalActivityThisWeekUseCase() -> GetGlobalActivityThisWeekUseCase {
        return GetGlobalActivityThisWeekUseCase(
            globalAnalyticsRepository: dataLayer.getGlobalAnalyticsRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
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
    
    func getLessonUseCase() -> GetLessonUseCase {
        return GetLessonUseCase()
    }
    
    func getLessonsUseCase() -> GetLessonsUseCase {
        return GetLessonsUseCase(
            getLessonUseCase: getLessonUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            cruOktaAuthentication: dataLayer.getCruOktaAuthentication(),
            firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics,
            snowplowAnalytics: dataLayer.getAnalytics().snowplowAnalytics
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
            getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase(),
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getShouldShowLanguageSettingsBarButtonUseCase() -> GetShouldShowLanguageSettingsBarButtonUseCase {
        return GetShouldShowLanguageSettingsBarButtonUseCase()
    }
    
    func getSpotlightToolsUseCase() -> GetSpotlightToolsUseCase {
        return GetSpotlightToolsUseCase(
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
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
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository()
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
            translationsRepository: dataLayer.getTranslationsRepository()
        )
    }
    
    func getToolVersionsUseCase() -> GetToolVersionsUseCase {
        return GetToolVersionsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository(),
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
    
    func getUserAccountProfileNameUseCase() -> GetUserAccountProfileNameUseCase {
        return GetUserAccountProfileNameUseCase(
            cruOktaAuthentication: dataLayer.getCruOktaAuthentication()
        )
    }
    
    func getUserDetailsUseCase() -> GetUserDetailsUseCase {
        return GetUserDetailsUseCase(
            repository: dataLayer.getUserDetailsRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getUserIsAuthenticatedUseCase() -> GetUserIsAuthenticatedUseCase {
        return GetUserIsAuthenticatedUseCase(
            cruOktaAuthentication: dataLayer.getCruOktaAuthentication()
        )
    }
}
