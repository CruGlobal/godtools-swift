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
    
    var scrollToTopSignal = PassthroughSubject<Bool, Never>()
    
    // UseCases
    private let reloadAllToolsFromCacheUseCase: ReloadAllToolsFromCacheUseCase
    
    // Services
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
    
    // MARK: - Init
    
    init(flowDelegate: FlowDelegate, reloadAllToolsFromCacheUseCase: ReloadAllToolsFromCacheUseCase, dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, favoritingToolMessageCache: FavoritingToolMessageCache, analytics: AnalyticsContainer) {
        self.flowDelegate = flowDelegate
        self.reloadAllToolsFromCacheUseCase = reloadAllToolsFromCacheUseCase
        self.dataDownloader = dataDownloader
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.analytics = analytics
        
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
    
    func cardViewModel(for tool: ResourceModel) -> ToolCardViewModel {
        let getBannerImageUseCase = DefaultGetBannerImageUseCase(
            resource: tool,
            dataDownloader: dataDownloader,
            deviceAttachmentBanners: deviceAttachmentBanners
        )
        let getToolDataUseCase = DefaultGetToolDataUseCase(
            resource: tool,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices
        )
        let getLanguageNameUseCase = DefaultGetLanguageNameUseCase(
            resource: tool,
            localizationServices: localizationServices
        )
        
        return ToolCardViewModel(
            resourceId: tool.id,
            getBannerImageUseCase: getBannerImageUseCase,
            getToolDataUseCase: getToolDataUseCase,
            getLanguageNameUseCase: getLanguageNameUseCase,
            favoritedResourcesCache: favoritedResourcesCache,
            languageSettingsService: languageSettingsService
        )
    }
    
    func refreshTools() {
        dataDownloader.downloadInitialData()
    }
    
    func createFavoritingToolMessageViewModel() -> FavoritingToolMessageViewModelType {
        
        return FavoritingToolMessageViewModel(
            favoritingToolMessageCache: favoritingToolMessageCache,
            localizationServices: localizationServices
        )
    }
    
    func scrollToTop(animated: Bool) {
        scrollToTopSignal.send(animated)
    }
    
    func toolTapped(resource: ResourceModel) {
        trackToolTappedAnalytics()
        flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
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
        tools = reloadAllToolsFromCacheUseCase.reload()
        isLoading = false
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
