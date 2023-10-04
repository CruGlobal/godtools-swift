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
    
    func getAppUIDebuggingIsEnabledUseCase() -> GetAppUIDebuggingIsEnabledUseCase {
        return GetAppUIDebuggingIsEnabledUseCase(
            appBuild: dataLayer.getAppBuild()
        )
    }
    
    func getAppVersionUseCase() -> GetAppVersionUseCase {
        return GetAppVersionUseCase(
            infoPlist: dataLayer.getInfoPlist()
        )
    }
    
    func getAuthenticateUserUseCase() -> AuthenticateUserUseCase {
        return AuthenticateUserUseCase(
            userAuthentication: dataLayer.getUserAuthentication(),
            emailSignUpService: dataLayer.getEmailSignUpService(),
            firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    
    
    func getDeleteAccountUseCase() -> DeleteAccountUseCase {
        return DeleteAccountUseCase(
            userAuthentication: dataLayer.getUserAuthentication(),
            userDetailsRepository: dataLayer.getUserDetailsRepository()
        )
    }
    
    func getDeviceLanguageUseCase() -> GetDeviceLanguageUseCase {
        return GetDeviceLanguageUseCase(
            getDeviceLanguageRepositoryInterface: dataLayer.getDeviceLanguageRepositoryInterface()
        )
    }
    
    func getDisableOptInOnboardingBannerUseCase() -> DisableOptInOnboardingBannerUseCase {
        return DisableOptInOnboardingBannerUseCase(
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getFeaturedLessonsUseCase() -> GetFeaturedLessonsUseCase {
        return GetFeaturedLessonsUseCase(
            getLessonUseCase: getLessonUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase()
        )
    }
    
    func getGlobalActivityThisWeekUseCase() -> GetGlobalActivityThisWeekUseCase {
        return GetGlobalActivityThisWeekUseCase(
            globalAnalyticsRepository: dataLayer.getGlobalAnalyticsRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getIncrementUserCounterUseCase() -> IncrementUserCounterUseCase {
        return IncrementUserCounterUseCase(
            userCountersRepository: dataLayer.getUserCountersRepository()
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
    
    func getLearnToShareToolItemsUseCase() -> GetLearnToShareToolItemsUseCase {
        return GetLearnToShareToolItemsUseCase(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getLessonUseCase() -> GetLessonUseCase {
        return GetLessonUseCase(
            translationsRepository: dataLayer.getTranslationsRepository(),
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase()
        )
    }
    
    func getLessonsUseCase() -> GetLessonsUseCase {
        return GetLessonsUseCase(
            getLessonUseCase: getLessonUseCase(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            userAuthentication: dataLayer.getUserAuthentication(),
            firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics
        )
    }
    
    func getOptInOnboardingBannerEnabledUseCase() -> GetOptInOnboardingBannerEnabledUseCase {
        return GetOptInOnboardingBannerEnabledUseCase(
            getOptInOnboardingTutorialAvailableUseCase: getOptInOnboardingTutorialAvailableUseCase(),
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getOptInOnboardingTutorialAvailableUseCase() -> GetOptInOnboardingTutorialAvailableUseCase {
        return GetOptInOnboardingTutorialAvailableUseCase(
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getOnboardingQuickLinksEnabledUseCase() -> GetOnboardingQuickLinksEnabledUseCase {
        return GetOnboardingQuickLinksEnabledUseCase(
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getOnboardingQuickStartItemsUseCase() -> GetOnboardingQuickStartItemsUseCase {
        return GetOnboardingQuickStartItemsUseCase(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getOnboardingTutorialAvailabilityUseCase() -> GetOnboardingTutorialAvailabilityUseCase {
        return GetOnboardingTutorialAvailabilityUseCase(
            launchCountRepository: dataLayer.getSharedLaunchCountRepository(),
            onboardingTutorialViewedRepository: dataLayer.getOnboardingTutorialViewedRepository()
        )
    }
    
    func getRemoveToolFromFavoritesUseCase() -> RemoveToolFromFavoritesUseCase {
        return RemoveToolFromFavoritesUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }
    
    func getSetCompletedTrainingTipUseCase() -> SetCompletedTrainingTipUseCase {
        return SetCompletedTrainingTipUseCase(
            repository: dataLayer.getCompletedTrainingTipRepository()
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
    
    func getShareableImageUseCase() -> GetShareableImageUseCase {
        return GetShareableImageUseCase()
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
            launchCountRepository: dataLayer.getSharedLaunchCountRepository()
        )
    }
    
    func getToggleToolFavoritedUseCase() -> ToggleToolFavoritedUseCase {
        return ToggleToolFavoritedUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            addToolToFavoritesUseCase: getAddToolToFavoritesUseCase(),
            removeToolFromFavoritesUseCase: getRemoveToolFromFavoritesUseCase()
        )
    }
    
    func getToolCategoriesUseCase() -> GetToolCategoriesUseCase {
        return GetToolCategoriesUseCase(
            getAllToolsUseCase: getAllToolsUseCase(),
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
    
    func getToolFilterLanguagesUseCase() -> GetToolFilterLanguagesUseCase {
        return GetToolFilterLanguagesUseCase(
            getAllToolsUseCase: getAllToolsUseCase(),
            getLanguageUseCase: getLanguageUseCase(),
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase(),
            languagesRepository: dataLayer.getLanguagesRepository(),
            localizationServices: dataLayer.getLocalizationServices()
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
            languagesRepository: dataLayer.getLanguagesRepository(),
            getLanguageUseCase: getLanguageUseCase()
        )
    }
    
    func getTrackActionAnalyticsUseCase() -> TrackActionAnalyticsUseCase {
        return TrackActionAnalyticsUseCase(
            trackActionAnalytics: dataLayer.getAnalytics()
        )
    }
    
    func getTrackExitLinkAnalyticsUseCase() -> TrackExitLinkAnalyticsUseCase {
        return TrackExitLinkAnalyticsUseCase(
            trackExitLinkAnalytics: dataLayer.getAnalytics()
        )
    }
    
    func getTrackScreenViewAnalyticsUseCase() -> TrackScreenViewAnalyticsUseCase {
        return TrackScreenViewAnalyticsUseCase(
            trackScreenViewAnalytics: dataLayer.getAnalytics()
        )
    }
    
    func getTrainingTipCompletedUseCase() -> GetTrainingTipCompletedUseCase {
        return GetTrainingTipCompletedUseCase(
            repository: dataLayer.getCompletedTrainingTipRepository(),
            service: dataLayer.getViewedTrainingTipsService(),
            setCompletedTrainingTipUseCase: getSetCompletedTrainingTipUseCase()
        )
    }
    
    func getTutorialUseCase() -> GetTutorialUseCase {
        return GetTutorialUseCase(
            localizationServices: dataLayer.getLocalizationServices(),
            getDeviceLanguageUseCase: getDeviceLanguageUseCase()
        )
    }
    
    func getUserAccountDetailsUseCase() -> GetUserAccountDetailsUseCase {
        return GetUserAccountDetailsUseCase(
            repository: dataLayer.getUserDetailsRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getUserActivityBadgeUseCase() -> GetUserActivityBadgeUseCase {
        return GetUserActivityBadgeUseCase(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getUserActivityStatsUseCase() -> GetUserActivityStatsUseCase {
        return GetUserActivityStatsUseCase(
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getUserActivityUseCase() -> GetUserActivityUseCase {
        return GetUserActivityUseCase(
            getUserActivityBadgeUseCase: getUserActivityBadgeUseCase(),
            getUserActivityStatsUseCase: getUserActivityStatsUseCase(),
            userCounterRepository: dataLayer.getUserCountersRepository(),
            completedTrainingTipRepository: dataLayer.getCompletedTrainingTipRepository()
        )
    }
    
    func getUserIsAuthenticatedUseCase() -> GetUserIsAuthenticatedUseCase {
        return GetUserIsAuthenticatedUseCase(
            userAuthentication: dataLayer.getUserAuthentication()
        )
    }
}
