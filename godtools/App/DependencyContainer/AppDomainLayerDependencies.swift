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
        return GetAccountCreationIsSupportedUseCase()
    }
    
    func getAppUIDebuggingIsEnabledUseCase() -> GetAppUIDebuggingIsEnabledUseCase {
        return GetAppUIDebuggingIsEnabledUseCase(
            appBuild: dataLayer.getAppBuild()
        )
    }
    
    func getDeleteUserCountersUseCase() -> DeleteUserCountersUseCase {
        return DeleteUserCountersUseCase(
            repository: dataLayer.getUserCountersRepository()
        )
    }
    
    func getDisableOptInOnboardingBannerUseCase() -> DisableOptInOnboardingBannerUseCase {
        return DisableOptInOnboardingBannerUseCase(
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getIncrementUserCounterUseCase() -> IncrementUserCounterUseCase {
        return IncrementUserCounterUseCase(
            userCountersRepository: dataLayer.getUserCountersRepository()
        )
    }
    
    func getLanguageUseCase() -> GetLanguageUseCase {
        return GetLanguageUseCase(
            languagesRepository: dataLayer.getLanguagesRepository(),
            localizationServices: dataLayer.getLocalizationServices()
        )
    }
    
    func getLogOutUserUseCase() -> LogOutUserUseCase {
        return LogOutUserUseCase(
            userAuthentication: dataLayer.getUserAuthentication(),
            firebaseAnalytics: dataLayer.getAnalytics().firebaseAnalytics,
            deleteUserCountersUseCase: getDeleteUserCountersUseCase()
        )
    }
    
    func getMenuInterfaceStringsUseCase() -> GetMenuInterfaceStringsUseCase {
        return GetMenuInterfaceStringsUseCase(
            getInterfaceStringsRepositoryInterface: dataLayer.getMenuInterfaceStringsRepositoryInterface()
        )
    }
    
    func getOptInOnboardingBannerEnabledUseCase() -> GetOptInOnboardingBannerEnabledUseCase {
        return GetOptInOnboardingBannerEnabledUseCase(
            getOptInOnboardingTutorialAvailableUseCase: getOptInOnboardingTutorialAvailableUseCase(),
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getOptInOnboardingTutorialAvailableUseCase() -> GetOptInOnboardingTutorialAvailableUseCase {
        return GetOptInOnboardingTutorialAvailableUseCase()
    }

    func getSetCompletedTrainingTipUseCase() -> SetCompletedTrainingTipUseCase {
        return SetCompletedTrainingTipUseCase(
            repository: dataLayer.getCompletedTrainingTipRepository()
        )
    }
    
    func getShouldShowLanguageSettingsBarButtonUseCase() -> GetShouldShowLanguageSettingsBarButtonUseCase {
        return GetShouldShowLanguageSettingsBarButtonUseCase()
    }
    
    func getStoreInitialFavoritedToolsUseCase() -> StoreInitialFavoritedToolsUseCase {
        return StoreInitialFavoritedToolsUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            launchCountRepository: dataLayer.getSharedLaunchCountRepository()
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
            localizationServices: dataLayer.getLocalizationServices(),
            getTranslatedNumberCount: dataLayer.getTranslatedNumberCount()
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
    
    func getViewAccountUseCase() -> ViewAccountUseCase {
        return ViewAccountUseCase(
            getInterfaceStringsRepository: dataLayer.getAccountInterfaceStringsRepositoryInterface()
        )
    }
    
    func getViewSearchBarUseCase() -> ViewSearchBarUseCase {
        return ViewSearchBarUseCase(
            getInterfaceStringsRepository: dataLayer.getSearchBarInterfaceStringsRepositoryInterface()
        )
    }
}
