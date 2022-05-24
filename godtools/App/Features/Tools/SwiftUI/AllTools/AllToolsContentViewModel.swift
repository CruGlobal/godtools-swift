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
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
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
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
    }
}

// MARK: - Public

extension AllToolsContentViewModel {
    
    func spotlightViewModel() -> ToolSpotlightViewModel {
        return ToolSpotlightViewModel(
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            delegate: self
        )
    }
    
    func categoriesViewModel() -> ToolCategoriesViewModel {
        return ToolCategoriesViewModel(
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
    }
    
    func cardViewModel(for tool: ResourceModel) -> ToolCardViewModel {
        return ToolCardViewModel(
            resource: tool,
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
    }
    
    func favoritingToolBannerViewModel() -> FavoritingToolBannerViewModel {
        
        return FavoritingToolBannerViewModel(localizationServices: localizationServices, delegate: self)
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
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.isLoading = !cachedResourcesAvailable
                if cachedResourcesAvailable {
                    self.reloadResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadResourcesFromCache()
                }
            }
        }
    }
    
    private func reloadResourcesFromCache() {
        let sortedResources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        let resources: [ResourceModel] = sortedResources.filter({
            let resourceType: ResourceType = $0.resourceTypeEnum
            return (resourceType == .tract || resourceType == .article || resourceType == .chooseYourOwnAdventure) && !$0.isHidden
        })
        
        tools = resources
        isLoading = false
    }
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
