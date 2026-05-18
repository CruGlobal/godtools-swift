//
//  AppDomainLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

final class AppDomainLayerDependencies {
        
    private let dataLayer: AppDataLayerDependencies
    
    let supporting: AppSupportingDomainLayerDependencies
    
    init(dataLayer: AppDataLayerDependencies) {
        
        self.dataLayer = dataLayer
        self.supporting = AppSupportingDomainLayerDependencies(dataLayer: dataLayer)
    }
    
    func getAppUIDebuggingIsEnabledUseCase() -> GetAppUIDebuggingIsEnabledUseCase {
        return GetAppUIDebuggingIsEnabledUseCase(
            appConfig: dataLayer.getAppConfig()
        )
    }
    
    func getSetCompletedTrainingTipUseCase() -> SetCompletedTrainingTipUseCase {
        return SetCompletedTrainingTipUseCase(
            repository: dataLayer.getCompletedTrainingTipRepository()
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
            getSearchBarStrings: supporting.getSearchBarStrings()
        )
    }
}
