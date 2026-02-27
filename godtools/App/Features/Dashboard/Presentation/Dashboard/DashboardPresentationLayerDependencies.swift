//
//  DashboardPresentationLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor class DashboardPresentationLayerDependencies {
    
    private let appDiContainer: AppDiContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    lazy var lessonsViewModel: LessonsViewModel = {
        return getLessonsViewModel()
    }()
    
    lazy var favoritesViewModel: FavoritesViewModel = {
        return getFavoritesViewModel()
    }()
    
    lazy var toolsViewModel: ToolsViewModel = {
        return getToolsViewModel()
    }()
    
    init(appDiContainer: AppDiContainer, flowDelegate: FlowDelegate) {
        
        self.appDiContainer = appDiContainer
        self.flowDelegate = flowDelegate
    }
    
    private var unwrappedFlowDelegate: FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    private func getLessonsViewModel() -> LessonsViewModel {
        
        return LessonsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            pullToRefreshLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getPullToRefreshLessonsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getGetLocalizationSettingsUseCase(),
            getPersonalizedLessonsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getGetPersonalizedLessonsUseCase(),
            getLessonsStringsUseCase: appDiContainer.feature.lessons.domainLayer.getLessonsStringsUseCase(),
            getAllLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getAllLessonsUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter.domainLayer.getUserLessonFiltersUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase()
        )
    }
    
    private func getFavoritesViewModel() -> FavoritesViewModel {
        
        return FavoritesViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            getFavoritesStringsUseCase: appDiContainer.feature.favorites.domainLayer.getFavoritesStringsUseCase(),
            getYourFavoritedToolsUseCase: appDiContainer.feature.favorites.domainLayer.getYourFavoritedToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
    }
    
    private func getToolsViewModel() -> ToolsViewModel {
        
        return ToolsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            pullToRefreshToolsUseCase: appDiContainer.feature.tools.domainLayer.getPullToRefreshToolsUseCase(),
            getToolsStringsUseCase: appDiContainer.feature.tools.domainLayer.getToolsStringsUseCase(),
            getAllToolsUseCase: appDiContainer.feature.tools.domainLayer.getAllToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            getLocalizationSettingsUseCase: appDiContainer.feature.personalizedTools.domainLayer.getGetLocalizationSettingsUseCase(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserToolFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites.domainLayer.getToggleToolFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            getToolBannerUseCase: appDiContainer.domainLayer.getToolBannerUseCase()
        )
    }
}
