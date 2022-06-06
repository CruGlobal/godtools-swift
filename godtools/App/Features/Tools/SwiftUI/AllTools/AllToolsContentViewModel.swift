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
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let analytics: AnalyticsContainer
        
    private var spotlightViewModel: ToolSpotlightViewModel?
    private var categoriesViewModel: ToolCategoriesViewModel?
    private var toolCardsViewModel: ToolCardsViewModel?
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    @Published var hideFavoritingToolBanner: Bool
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        self.hideFavoritingToolBanner = favoritingToolMessageCache.favoritingToolMessageDisabled
        
        super.init()
    }
}

// MARK: - Public

extension AllToolsContentViewModel {
    
    func getFavoritingToolBannerViewModel() -> FavoritingToolBannerViewModel {
        
        return FavoritingToolBannerViewModel(localizationServices: localizationServices, delegate: self)
    }
    
    func getSpotlightViewModel() -> ToolSpotlightViewModel {
        if let spotlightViewModel = spotlightViewModel {
            return spotlightViewModel
            
        } else {
            let spotlightVM = ToolSpotlightViewModel(
                dataDownloader: dataDownloader,
                deviceAttachmentBanners: deviceAttachmentBanners,
                favoritedResourcesCache: favoritedResourcesCache,
                languageSettingsService: languageSettingsService,
                localizationServices: localizationServices,
                delegate: self
            )
            
            spotlightViewModel = spotlightVM
            return spotlightVM
        }
    }
    
    func getCategoriesViewModel() -> ToolCategoriesViewModel {
        if let categoriesViewModel = categoriesViewModel {
            return categoriesViewModel
            
        } else {
            let categoriesVM = ToolCategoriesViewModel(
                dataDownloader: dataDownloader,
                languageSettingsService: languageSettingsService,
                localizationServices: localizationServices,
                delegate: self
            )
            
            categoriesViewModel = categoriesVM
            return categoriesVM
        }
    }
    
    func getToolCardsViewModel() -> ToolCardsViewModel {
        if let toolCardsViewModel = toolCardsViewModel {
            return toolCardsViewModel
            
        } else {
            let toolCardsVM = ToolCardsViewModel(
                dataDownloader: dataDownloader,
                deviceAttachmentBanners: deviceAttachmentBanners,
                languageSettingsService: languageSettingsService,
                localizationServices: localizationServices,
                favoritedResourcesCache: favoritedResourcesCache,
                analytics: analytics
            )
            
            toolCardsViewModel = toolCardsVM
            return toolCardsVM
        }
    }
    
    func refreshTools() {
        dataDownloader.downloadInitialData()
    }
    
    func toolTapped(resource: ResourceModel) {
        trackToolTappedAnalytics()
        flowDelegate?.navigate(step: .aboutToolTappedFromAllTools(resource: resource))
    }
}

// MARK: - Private

extension AllToolsContentViewModel {
}

// MARK: - FavoritingToolBannerDelegate

extension AllToolsContentViewModel: FavoritingToolBannerDelegate {
    
    func closeBanner() {
        hideFavoritingToolBanner = true
        favoritingToolMessageCache.disableFavoritingToolMessage()
    }
}

// MARK: - ToolSpotlightDelegate

extension AllToolsContentViewModel: ToolSpotlightDelegate {
    
    func spotlightCardTapped(resource: ResourceModel) {
        toolTapped(resource: resource)
    }
}

// MARK: - ToolCategoriesViewModelDelegate

extension AllToolsContentViewModel: ToolCategoriesViewModelDelegate {
    
    func filterToolsWithCategory(_ attrCategory: String?) {
        toolCardsViewModel?.filterTools(with: attrCategory)
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
            
    private func trackToolTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.toolOpenTapped, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.toolOpenTapped: 1]))
    }
}
