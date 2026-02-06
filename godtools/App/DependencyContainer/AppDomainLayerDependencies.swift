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
    
    func getAppUIDebuggingIsEnabledUseCase() -> GetAppUIDebuggingIsEnabledUseCase {
        return GetAppUIDebuggingIsEnabledUseCase(
            appConfig: dataLayer.getAppConfig()
        )
    }
    
    func getDisableOptInOnboardingBannerUseCase() -> DisableOptInOnboardingBannerUseCase {
        return DisableOptInOnboardingBannerUseCase(
            optInOnboardingBannerEnabledRepository: dataLayer.getOptInOnboardingBannerEnabledRepository()
        )
    }
    
    func getDownloadLatestToolsForFavoritedToolsUseCase() -> DownloadLatestToolsForFavoritedToolsUseCase {
        return DownloadLatestToolsForFavoritedToolsUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository(),
            resourcesRepository: dataLayer.getResourcesRepository(),
            toolDownloader: dataLayer.getToolDownloader()
        )
    }
    
    func getLessonsListItems() -> GetLessonsListItems {
        return GetLessonsListItems(
            languagesRepository: dataLayer.getLanguagesRepository(),
            getTranslatedToolName: dataLayer.getTranslatedToolName(),
            getTranslatedToolLanguageAvailability: dataLayer.getTranslatedToolLanguageAvailability(),
            getLessonListItemProgressRepository: dataLayer.getLessonListItemProgressRepository()
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
    
    func getStoreInitialFavoritedToolsUseCase() -> StoreInitialFavoritedToolsUseCase {
        return StoreInitialFavoritedToolsUseCase(
            favoritedResourcesRepository: dataLayer.getFavoritedResourcesRepository()
        )
    }

    func getToolBannerUseCase() -> GetToolBannerUseCase {
        return GetToolBannerUseCase(
            attachmentsRepository: dataLayer.getAttachmentsRepository()
        )
    }
    
    func getToolTranslationsFilesUseCase() -> GetToolTranslationsFilesUseCase {
        return GetToolTranslationsFilesUseCase(
            resourcesRepository: dataLayer.getResourcesRepository(),
            translationsRepository: dataLayer.getTranslationsRepository(),
            languagesRepository: dataLayer.getLanguagesRepository()
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
            repository: dataLayer.getCompletedTrainingTipRepository()
        )
    }
    
    func getViewSearchBarUseCase() -> ViewSearchBarUseCase {
        return ViewSearchBarUseCase(
            getInterfaceStringsRepository: dataLayer.getSearchBarInterfaceStringsRepositoryInterface()
        )
    }
}
