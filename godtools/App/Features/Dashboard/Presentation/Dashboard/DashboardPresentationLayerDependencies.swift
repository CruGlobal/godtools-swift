//
//  DashboardPresentationLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
final class DashboardPresentationLayerDependencies {
    
    private let appDiContainer: AppDiContainer
    private let stepEmitter: FlowStepEmitter
        
    lazy var lessonsViewModel: LessonsViewModel = {
        return getLessonsViewModel()
    }()
    
    lazy var favoritesViewModel: FavoritesViewModel = {
        return getFavoritesViewModel()
    }()
    
    lazy var toolsViewModel: ToolsViewModel = {
        return getToolsViewModel()
    }()
    
    init(appDiContainer: AppDiContainer, stepEmitter: FlowStepEmitter) {
        
        self.appDiContainer = appDiContainer
        self.stepEmitter = stepEmitter
    }
    
    private func getLessonsViewModel() -> LessonsViewModel {
        
        return LessonsViewModel(
            stepEmitter: stepEmitter,
            pullToRefreshLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getPullToRefreshLessonsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsUseCase(),
            getPersonalizedLessonsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getPersonalizedLessonsUseCase(),
            getLessonsStringsUseCase: appDiContainer.feature.lessons.domainLayer.getLessonsStringsUseCase(),
            getAllLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getAllLessonsUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache()
        )
    }
    
    private func getFavoritesViewModel() -> FavoritesViewModel {
        
        return FavoritesViewModel(
            stepEmitter: stepEmitter,
            resourcesRepository: appDiContainer.core.dataLayer.getResourcesRepository(),
            getFavoritesStringsUseCase: appDiContainer.feature.favorites.domainLayer.getFavoritesStringsUseCase(),
            getYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache(),
            disableOptInOnboardingBannerUseCase: appDiContainer.feature.tools.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.feature.tools.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase()
        )
    }
    
    private func getToolsViewModel() -> ToolsViewModel {

        return ToolsViewModel(
            stepEmitter: stepEmitter,
            pullToRefreshToolsUseCase: appDiContainer.feature.tools.domainLayer.getPullToRefreshToolsUseCase(),
            getToolsStringsUseCase: appDiContainer.feature.tools.domainLayer.getToolsStringsUseCase(),
            getAllToolsUseCase: appDiContainer.feature.tools.domainLayer.getAllToolsUseCase(),
            getPersonalizedToolsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getPersonalizedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getLocalizationSettingsUseCase(),
            favoritingToolMessageCache: appDiContainer.core.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getUserToolFilterCategoryUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterCategoryUseCase(),
            getUserToolFilterLanguageUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFilterLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.core.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.core.domainLayer.getToolBannerUseCase(),
            imageCache: appDiContainer.core.dataLayer.getSharedImageCache()
        )
    }
}
