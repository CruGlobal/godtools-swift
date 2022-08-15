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
    
    private let removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase
    
    override var tools: [ResourceModel] {
        didSet {
            if tools.isEmpty {
                closePage()
            }
        }
    }
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, flowDelegate: FlowDelegate?, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        
        super.init(dataDownloader: dataDownloader, languageSettingsService: languageSettingsService, localizationServices: localizationServices, getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase, getBannerImageUseCase: getBannerImageUseCase, getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: getToolIsFavoritedUseCase, delegate: nil, toolCardViewModelDelegate: nil)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            resource: tool,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
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
        trackOpenFavoritedToolButtonAnalytics(for: resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func toolFavoriteButtonTapped(resource: ResourceModel) {
        let removedHandler = CallbackHandler { [weak self] in
            self?.removeToolFromFavoritesUseCase.removeToolFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(resource: ResourceModel) {
        trackFavoritedToolDetailsButtonAnalytics(for: resource)
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolButtonTapped(resource: ResourceModel) {
        trackOpenFavoritedToolButtonAnalytics(for: resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
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
    
    private func trackOpenFavoritedToolButtonAnalytics(for tool: ResourceModel) {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.toolOpened,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        ))
    }
    
    private func trackFavoritedToolDetailsButtonAnalytics(for tool: ResourceModel) {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.openDetails,
            siteSection: "",
            siteSubSection: "",
            url: nil,
            data: [
                AnalyticsConstants.Keys.source: AnalyticsConstants.Sources.favoriteTools,
                AnalyticsConstants.Keys.tool: tool.abbreviation
            ]
        ))
    }
}

