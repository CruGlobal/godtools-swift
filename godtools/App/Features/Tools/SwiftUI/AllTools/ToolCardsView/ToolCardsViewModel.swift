//
//  ToolCardsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolCardsViewModelDelegate: AnyObject {
    func toolCardTapped(resource: ResourceModel)
    func toolsAreLoading(_ isLoading: Bool)
}

class ToolCardsViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private weak var flowDelegate: FlowDelegate?
    private let dataDownloader: InitialDataDownloader
    private let deviceAttachmentBanners: DeviceAttachmentBanners
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    private let favoritedResourcesCache: FavoritedResourcesCache
    private let analytics: AnalyticsContainer
    private weak var delegate: ToolCardsViewModelDelegate?
    
    private var categoryFilterValue: String?
    
    // MARK: - Published
    
    @Published var tools: [ResourceModel] = []
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, analytics: AnalyticsContainer, delegate: ToolCardsViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        self.delegate = delegate
        
        super.init()
        
        setupBinding()
    }
    
}

// MARK: - Private

extension ToolCardsViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.toolsAreLoading(!cachedResourcesAvailable)
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
        let categoryFilter: ResourceFilter? = categoryFilterValue == nil ? nil : { $0.attrCategory == self.categoryFilterValue }
        tools = dataDownloader.resourcesCache.getAllVisibleToolsSorted(andFilteredBy: categoryFilter)
        
        self.delegate?.toolsAreLoading(false)
    }
}

// MARK: - Public

extension ToolCardsViewModel {
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
    
    func toolTapped(resource: ResourceModel) {
        delegate?.toolCardTapped(resource: resource)
    }
    
    func filterTools(with attrCategory: String?) {
        categoryFilterValue = attrCategory
        reloadResourcesFromCache()
    }
}

// MARK: - Analytics

extension ToolCardsViewModel {
    var analyticsScreenName: String {
        return "All Tools"
    }
    
    private var analyticsSiteSection: String {
        return "home"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func trackToolTappedAnalytics() {
        analytics.trackActionAnalytics.trackAction(trackAction: TrackActionModel(screenName: analyticsScreenName, actionName: AnalyticsConstants.ActionNames.toolOpenTapped, siteSection: "", siteSubSection: "", url: nil, data: [AnalyticsConstants.Keys.toolOpenTapped: 1]))
    }
}
