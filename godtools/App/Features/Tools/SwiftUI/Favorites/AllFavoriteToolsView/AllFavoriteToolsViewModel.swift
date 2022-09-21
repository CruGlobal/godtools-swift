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
    
    override var tools: [ToolDomainModel] {
        didSet {
            if tools.isEmpty {
                closePage()
            }
        }
    }
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, removeToolFromFavoritesUseCase: RemoveToolFromFavoritesUseCase, flowDelegate: FlowDelegate?, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.analytics = analytics
        
        self.removeToolFromFavoritesUseCase = removeToolFromFavoritesUseCase
        
        super.init(dataDownloader: dataDownloader, localizationServices: localizationServices, getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase, getBannerImageUseCase: getBannerImageUseCase, getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: getToolIsFavoritedUseCase, toolCardViewModelDelegate: nil)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ToolDomainModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            tool: tool,
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
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
    
    func toolCardTapped(_ tool: ToolDomainModel) {
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: tool.resource))
    }
    
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel) {
        let removedHandler = CallbackHandler { [weak self] in
            self?.removeToolFromFavoritesUseCase.removeToolFromFavorites(resourceId: tool.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: tool.resource, removeHandler: removedHandler))
    }
    
    func toolDetailsButtonTapped(_ tool: ToolDomainModel) {
        trackFavoritedToolDetailsButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: tool.resource))
    }
    
    func openToolButtonTapped(_ tool: ToolDomainModel) {
        trackOpenFavoritedToolButtonAnalytics(for: tool.resource)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: tool.resource))
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

