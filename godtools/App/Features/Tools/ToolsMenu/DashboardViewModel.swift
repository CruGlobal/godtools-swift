//
//  DashboardViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class DashboardViewModel: ObservableObject {
    
    private let initialDataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
    
    private let disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase
    private let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getLessonsUseCase: GetLessonsUseCase
    private let getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
    
    private weak var flowDelegate: FlowDelegate?
    private var unwrappedFlowDelegate: FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
        
    lazy var allToolsViewModel: AllToolsContentViewModel = {
        AllToolsContentViewModel(
            flowDelegate: unwrappedFlowDelegate,
            dataDownloader: initialDataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritingToolMessageCache: favoritingToolMessageCache,
            analytics: analytics,
            getAllToolsUseCase: getAllToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getSpotlightToolsUseCase: getSpotlightToolsUseCase,
            getToolCategoriesUseCase: getToolCategoriesUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            toggleToolFavoritedUseCase: toggleToolFavoritedUseCase
        )
    }()
    
    required init(flowDelegate: FlowDelegate, initialDataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, disableOptInOnboardingBannerUseCase: DisableOptInOnboardingBannerUseCase, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getAllToolsUseCase: GetAllToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFeaturedLessonsUseCase: GetFeaturedLessonsUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getLessonsUseCase: GetLessonsUseCase, getOptInOnboardingBannerEnabledUseCase: GetOptInOnboardingBannerEnabledUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase, fontService: FontService) {
        
        self.flowDelegate = flowDelegate
        self.initialDataDownloader = initialDataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        
        self.disableOptInOnboardingBannerUseCase = disableOptInOnboardingBannerUseCase
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getFeaturedLessonsUseCase = getFeaturedLessonsUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getLessonsUseCase = getLessonsUseCase
        self.getOptInOnboardingBannerEnabledUseCase = getOptInOnboardingBannerEnabledUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
    }
}
