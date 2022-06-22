//
//  FavoritesContentViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

class FavoritesContentViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
        
    private weak var flowDelegate: FlowDelegate?
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let analytics: AnalyticsContainer
    
    private(set) lazy var favoriteToolsViewModel: FavoriteToolsViewModel = {
        return FavoriteToolsViewModel(
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
    }()
    
    // MARK: - Published
    
    @Published var isLoading: Bool = false
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        
        super.init()
    }
}

// MARK: - Public

extension FavoritesContentViewModel {
    func refreshTools() {
        dataDownloader.downloadInitialData()
    }
}

// MARK: - Analytics

extension FavoritesContentViewModel {
    var analyticsScreenName: String {
        return "Favorites"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
        
        analytics.firebaseAnalytics.trackAction(screenName: "", siteSection: "", siteSubSection: "", actionName: AnalyticsConstants.ActionNames.viewedMyToolsAction, data: nil)
        
        flowDelegate?.navigate(step: .userViewedFavoritedToolsListFromTools)
    }
}
