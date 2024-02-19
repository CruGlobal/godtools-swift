//
//  DashboardPresentationLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DashboardPresentationLayerDependencies {
    
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
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            viewLessonsUseCase: appDiContainer.feature.lessons.domainLayer.getViewLessonsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
    }
    
    private func getFavoritesViewModel() -> FavoritesViewModel {
        
        return FavoritesViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            viewFavoritesUseCase: appDiContainer.feature.favorites.domainLayer.getViewFavoritesUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
    }
    
    private func getToolsViewModel() -> ToolsViewModel {
        
        return ToolsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer.getResourcesRepository(),
            viewToolsUseCase: appDiContainer.feature.dashboard.domainLayer.getViewToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getCurrentAppLanguageUseCase(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools.domainLayer.getSpotlightToolsUseCase(),
            getToolFilterCategoriesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterCategoriesUseCase(),
            getToolFilterLanguagesUseCase: appDiContainer.feature.toolsFilter.domainLayer.getToolFilterLanguagesUseCase(),
            getUserFiltersUseCase: appDiContainer.feature.toolsFilter.domainLayer.getUserFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
    }
}
