//
//  AllToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AllToolsViewModel: NSObject, AllToolsViewModelType {
    
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let dataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let localizationServices: LocalizationServices
    let favoritedResourcesCache: FavoritedResourcesCache
    let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    let deviceAttachmentBanners: DeviceAttachmentBanners
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsAdded: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let toolListIsEditable: Bool = false
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel, deviceAttachmentBanners: DeviceAttachmentBanners, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.analytics = analytics
        
        super.init()
                 
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading.accept(value: !cachedResourcesAvailable)
                if cachedResourcesAvailable {
                    self?.reloadResourcesFromCache()
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
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadTool(resourceId: resourceId)
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadTool(resourceId: resourceId)
            }
        }
    }
    
    private func reloadResourcesFromCache() {
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getSortedResources()
        tools.accept(value: resources)
        isLoading.accept(value: false)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func toolTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func aboutToolTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .aboutToolTappedFromAllTools(resource: resource))
    }
    
    func openToolTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: ResourceModel) {
        
        favoritedResourcesCache.toggleFavorited(resourceId: resource.id)
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
