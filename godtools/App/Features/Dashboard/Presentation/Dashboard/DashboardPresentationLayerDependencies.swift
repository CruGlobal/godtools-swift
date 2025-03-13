//
//  DashboardPresentationLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 8/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class DashboardPresentationLayerDependencies {

    // Store a reference to dependency injection container
    private let appDiContainer: AppDiContainer

    // Weak reference to prevent 'retain cycles'
    private weak var flowDelegate: FlowDelegate?

    // Lazily instantiated properties for ViewModels (only created when accessed)
    lazy var lessonsViewModel: LessonsViewModel = {
        return getLessonsViewModel()
    }()

    lazy var favoritesViewModel: FavoritesViewModel = {
        return getFavoritesViewModel()
    }()

    lazy var toolsViewModel: ToolsViewModel = {
        return getToolsViewModel()
    }()

    lazy var notificationsViewModel: NotificationsViewModel = {
        return getNotificationsViewModel()
    }()

    // Initializes dependencies
    init(appDiContainer: AppDiContainer, flowDelegate: FlowDelegate) {

        self.appDiContainer = appDiContainer
        self.flowDelegate = flowDelegate
    }

    // Ensures flow delegate is non nil
    private var unwrappedFlowDelegate: FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }

    // Getters create and return view models with required fields
    private func getLessonsViewModel() -> LessonsViewModel {

        return LessonsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer
                .getResourcesRepository(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase(),
            getUserLessonFiltersUseCase: appDiContainer.feature.lessonFilter
                .domainLayer.getUserLessonFiltersUseCase(),
            viewLessonsUseCase: appDiContainer.feature.lessons.domainLayer
                .getViewLessonsUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer
                .getAttachmentsRepository()
        )
    }

    private func getFavoritesViewModel() -> FavoritesViewModel {

        return FavoritesViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer
                .getResourcesRepository(),
            viewFavoritesUseCase: appDiContainer.feature.favorites.domainLayer
                .getViewFavoritesUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites
                .domainLayer.getToolIsFavoritedUseCase(),
            attachmentsRepository: appDiContainer.dataLayer
                .getAttachmentsRepository(),
            disableOptInOnboardingBannerUseCase: appDiContainer.domainLayer
                .getDisableOptInOnboardingBannerUseCase(),
            getFeaturedLessonsUseCase: appDiContainer.feature.featuredLessons
                .domainLayer.getFeaturedLessonsUseCase(),
            getOptInOnboardingBannerEnabledUseCase: appDiContainer.domainLayer
                .getOptInOnboardingBannerEnabledUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackActionAnalyticsUseCase()
        )
    }

    private func getToolsViewModel() -> ToolsViewModel {

        return ToolsViewModel(
            flowDelegate: unwrappedFlowDelegate,
            resourcesRepository: appDiContainer.dataLayer
                .getResourcesRepository(),
            viewToolsUseCase: appDiContainer.feature.dashboard.domainLayer
                .getViewToolsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase(),
            favoritingToolMessageCache: appDiContainer.dataLayer
                .getFavoritingToolMessageCache(),
            getSpotlightToolsUseCase: appDiContainer.feature.spotlightTools
                .domainLayer.getSpotlightToolsUseCase(),
            getUserToolFiltersUseCase: appDiContainer.feature.toolsFilter
                .domainLayer.getUserToolFiltersUseCase(),
            getToolIsFavoritedUseCase: appDiContainer.feature.favorites
                .domainLayer.getToolIsFavoritedUseCase(),
            toggleToolFavoritedUseCase: appDiContainer.feature.favorites
                .domainLayer.getToggleFavoritedToolUseCase(),
            trackScreenViewAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackScreenViewAnalyticsUseCase(),
            trackActionAnalyticsUseCase: appDiContainer.domainLayer
                .getTrackActionAnalyticsUseCase(),
            attachmentsRepository: appDiContainer.dataLayer
                .getAttachmentsRepository()
        )
    }

    private func getNotificationsViewModel() -> NotificationsViewModel {

        return NotificationsViewModel(
            viewOptInNotificationsUseCase: ViewOptInNotificationsUseCase(),
            getCurrentAppLanguageUseCase: appDiContainer.feature.appLanguage
                .domainLayer.getCurrentAppLanguageUseCase()
        )
    }
}
