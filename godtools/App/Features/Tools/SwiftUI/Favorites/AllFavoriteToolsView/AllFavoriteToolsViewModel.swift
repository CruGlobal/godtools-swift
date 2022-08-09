//
//  AllFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AllFavoriteToolsViewModel: BaseFavoriteToolsViewModel {
    
    // MARK: - Properties
    
    private weak var flowDelegate: FlowDelegate?
    private let analytics: AnalyticsContainer
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, flowDelegate: FlowDelegate?, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        
        super.init(dataDownloader: dataDownloader, favoritedResourcesCache: favoritedResourcesCache, languageSettingsService: languageSettingsService, localizationServices: localizationServices, getBannerImageUseCase: getBannerImageUseCase, getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase, delegate: nil, toolCardViewModelDelegate: nil)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            resource: tool,
            dataDownloader: dataDownloader,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            delegate: self
        )
    }
    
    override func removeFavoritedResource(resourceIds: [String]) {
        super.removeFavoritedResource(resourceIds: resourceIds)
        
        if tools.isEmpty {
            closePage()
        }
    }
}

// MARK: - Public

extension AllFavoriteToolsViewModel {
    
    func backButtonTapped() {
        closePage()
    }
}

// MARK: - Private

extension AllFavoriteToolsViewModel {
    
    func closePage() {
        flowDelegate?.navigate(step: .backTappedFromAllFavoriteTools)
    }
}

// MARK: - ToolCardViewModelDelegate

extension AllFavoriteToolsViewModel: ToolCardViewModelDelegate {
    func toolCardTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
        trackFavoritedToolTappedAnalytics()
    }
    
    func toolFavoriteButtonTapped(resource: ResourceModel) {
        let removedHandler = CallbackHandler { [weak self] in
            self?.favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolButtonTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
        trackOpenFavoritedToolButtonAnalytics()
    }
}

// MARK: - Analytics

extension AllFavoriteToolsViewModel {
    var analyticsScreenName: String {
        return "All Favorites"
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
    
    private func trackFavoritedToolTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpenTapped,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.toolOpenTapped: 1]
        ))
    }
    
    private func trackOpenFavoritedToolButtonAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [AnalyticsConstants.Keys.toolOpened: 1]
        ))
    }
}

