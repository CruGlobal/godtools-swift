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
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            getLessonsListUseCase: appDiContainer.feature.lessons.domainLayer.getLessonsListUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
    }
    
    private func getFavoritesViewModel() -> FavoritesViewModel {
        
        return FavoritesViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer.getDisableOptInOnboardingBannerUseCase(),
            getAllFavoritedToolsUseCase: appDiContainer.domainLayer.getAllFavoritedToolsUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons.domainLayer.getFeaturedLessonsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.domainLayer.getOptInOnboardingBannerEnabledUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase()
        )
    }
    
    private func getToolsViewModel() -> ToolsViewModel {
        
        return ToolsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: appDiContainer.dataLayer.getInitialDataDownloader(),
            favoritingToolMessageCache: appDiContainer.dataLayer.getFavoritingToolMessageCache(),
            getAllToolsUseCase: appDiContainer.domainLayer.getAllToolsUseCase(),
            getLanguageAvailabilityUseCase: appDiContainer.domainLayer.getLanguageAvailabilityUseCase(),
            getSpotlightToolsUseCase: appDiContainer.domainLayer.getSpotlightToolsUseCase(),
            getToolCategoriesUseCase: appDiContainer.domainLayer.getToolCategoriesUseCase(),
            getToolFilterLanguagesUseCase: appDiContainer.domainLayer.getToolFilterLanguagesUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.domainLayer.getToggleToolFavoritedUseCase(),
            getInterfaceStringInAppLanguageUseCase: appDiContainer.feature.appLanguage.domainLayer.getInterfaceStringInAppLanguageUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer.getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer.getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer.getAttachmentsRepository()
        )
    }
}
