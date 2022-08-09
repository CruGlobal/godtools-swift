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
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
        
    private(set) lazy var spotlightViewModel: ToolSpotlightViewModel = {
        ToolSpotlightViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
    private(set) lazy var categoriesViewModel: ToolCategoriesViewModel = {
        ToolCategoriesViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            delegate: self
        )
    }()
    private(set) lazy var toolCardsViewModel: ToolCardsViewModel = {
        ToolCardsViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            favoritedResourcesCache: favoritedResourcesCache,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    @Published var hideFavoritingToolBanner: Bool
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        self.hideFavoritingToolBanner = favoritingToolMessageCache.favoritingToolMessageDisabled
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
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
        trackToolTappedAnalytics(isSpotlight: isSpotlight)
        flowDelegate?.navigate(step: .aboutToolTappedFromAllTools(resource: resource))
    }
    
    private func handleToolFavoriteButtonTapped(resource: ResourceModel) {
        favoritedResourcesCache.toggleFavorited(resourceId: resource.id)
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
    
    func filterToolsWithCategory(_ attrCategory: String?) {
        toolCardsViewModel.filterTools(with: attrCategory)
    }
}

// MARK: - ToolCardsViewModelDelegate

extension AllToolsContentViewModel: ToolCardsViewModelDelegate {
    
    func toolCardTapped(resource: ResourceModel) {
        handleToolCardTapped(resource: resource, isSpotlight: false)
    }
    
    func toolFavoriteButtonTapped(resource: ResourceModel) {
        handleToolFavoriteButtonTapped(resource: resource)
    }
    
    func toolsAreLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func toolDetailsButtonTapped(resource: ResourceModel) {}
    func openToolButtonTapped(resource: ResourceModel) {}
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
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
            
    private func trackToolTappedAnalytics(isSpotlight: Bool) {
        
        var data: [String: Any] = [AnalyticsConstants.Keys.toolOpenTapped: 1]
        if isSpotlight {
            data[AnalyticsConstants.Keys.source] = AnalyticsConstants.Sources.spotlight
        }
        
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpenTapped,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: data
        ))
    }
}
