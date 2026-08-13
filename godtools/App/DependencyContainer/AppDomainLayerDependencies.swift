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
            appBuild: dataLayer.getAppBuild()
        )
    }
    
    func getSearchBarStringsUseCase() -> GetSearchBarStringsUseCase {
        return GetSearchBarStringsUseCase(
            localizationServices: dataLayer.getLocalizationServices()
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
    
    func getDownloadToolUseCase() -> DownloadToolUseCase {
        return DownloadToolUseCase(
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
            analytics: dataLayer.getAnalytics()
        )
    }
    
    func getTrainingTipCompletedUseCase() -> GetTrainingTipCompletedUseCase {
        return GetTrainingTipCompletedUseCase(
            repository: dataLayer.getCompletedTrainingTipRepository()
        )
    }
}
