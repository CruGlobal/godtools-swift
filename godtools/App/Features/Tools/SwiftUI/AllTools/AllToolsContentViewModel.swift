//
//  AllToolsContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class AllToolsContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
        
    private weak var flowDelegate: FlowDelegate?
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    private let getSpotlightToolsUseCase: GetSpotlightToolsUseCase
    private let getToolCategoriesUseCase: GetToolCategoriesUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    private let toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase
        
    private(set) lazy var spotlightViewModel: ToolSpotlightViewModel = {
        ToolSpotlightViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getSpotlightToolsUseCase: getSpotlightToolsUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
    private(set) lazy var categoriesViewModel: ToolCategoriesViewModel = {
        ToolCategoriesViewModel(
            localizationServices: localizationServices,
            getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase,
            getToolCategoriesUseCase: getToolCategoriesUseCase,
            delegate: self
        )
    }()
    private(set) lazy var toolCardsViewModel: ToolCardsViewModel = {
        ToolCardsViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getAllToolsUseCase: getAllToolsUseCase,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    @Published var hideFavoritingToolBanner: Bool
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, getAllToolsUseCase: GetAllToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSpotlightToolsUseCase: GetSpotlightToolsUseCase, getToolCategoriesUseCase: GetToolCategoriesUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toggleToolFavoritedUseCase: ToggleToolFavoritedUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        self.hideFavoritingToolBanner = favoritingToolMessageCache.favoritingToolMessageDisabled
        
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSpotlightToolsUseCase = getSpotlightToolsUseCase
        self.getToolCategoriesUseCase = getToolCategoriesUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.toggleToolFavoritedUseCase = toggleToolFavoritedUseCase
        
        super.init()
    }
}

// MARK: - Public

extension AllToolsContentViewModel {
    
    func getFavoritingToolBannerViewModel() -> FavoritingToolBannerViewModel {
        
        return FavoritingToolBannerViewModel(localizationServices: localizationServices, delegate: self)
    }
    
    func refreshTools() {
        dataDownloader.downloadInitialData()
    }
}

// MARK: - Private

extension AllToolsContentViewModel {
    
    private func handleToolCardTapped(resource: ResourceModel, isSpotlight: Bool) {
        trackToolTappedAnalytics(for: resource, isSpotlight: isSpotlight)
        flowDelegate?.navigate(step: .aboutToolTappedFromAllTools(resource: resource))
    }
    
    private func handleToolFavoriteButtonTapped(resource: ResourceModel) {
        toggleToolFavoritedUseCase.toggleToolFavorited(tool: resource)
    }
}

// MARK: - FavoritingToolBannerViewModelDelegate

extension AllToolsContentViewModel: FavoritingToolBannerViewModelDelegate {
    
    func closeBanner() {
        hideFavoritingToolBanner = true
        favoritingToolMessageCache.disableFavoritingToolMessage()
    }
}

// MARK: - ToolCategoriesViewModelDelegate

extension AllToolsContentViewModel: ToolCategoriesViewModelDelegate {
    
    func filterToolsWithCategory(_ categoryId: String?) {
        toolCardsViewModel.filterTools(with: categoryId)
    }
}

// MARK: - ToolCardsViewModelDelegate

extension AllToolsContentViewModel: ToolCardsViewModelDelegate {
    
    func toolCardTapped(_ tool: ToolDomainModel) {
        handleToolCardTapped(resource: tool.resource, isSpotlight: false)
    }
    
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel) {
        handleToolFavoriteButtonTapped(resource: tool.resource)
    }
    
    func toolsAreLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func toolDetailsButtonTapped(_ tool: ToolDomainModel) {}
    func openToolButtonTapped(_ tool: ToolDomainModel) {}
}

// MARK: - ToolSpotlightViewModelDelegate

extension AllToolsContentViewModel: ToolSpotlightViewModelDelegate {
    func spotlightToolCardTapped(resource: ResourceModel) {
        handleToolCardTapped(resource: resource, isSpotlight: true)
    }
    
    func spotlightToolFavoriteButtonTapped(resource: ResourceModel) {
        handleToolFavoriteButtonTapped(resource: resource)
    }
}

// MARK: - Analytics

extension AllToolsContentViewModel {
    
    var analyticsScreenName: String {
        return "All Tools"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.viewedToolsAction,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: nil
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
            
    private func trackToolTappedAnalytics(for tool: ResourceModel, isSpotlight: Bool) {
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: isSpotlight ? AnalyticsConstants.Sources.spotlight : AnalyticsConstants.Sources.allTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
