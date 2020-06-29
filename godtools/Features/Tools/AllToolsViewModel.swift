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
    let favoritedResourcesCache: FavoritedResourcesCache
    let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let toolListIsEditable: Bool = false
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, favoritedResourcesCache: FavoritedResourcesCache, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.favoritedResourcesCache = favoritedResourcesCache
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        self.analytics = analytics
        
        super.init()
        
        reloadResourcesFromCache()
         
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.started.removeObserver(self)
        dataDownloader.completed.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.started.addObserver(self) { [weak self] (started: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadIsLoading()
            }
        }
        
        dataDownloader.completed.addObserver(self) { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>?) in
            DispatchQueue.main.async { [weak self] in
                if result != nil {
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
               
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getResources()
        tools.accept(value: resources)
        reloadIsLoading()
    }
    
    private func reloadIsLoading() {
        
        let isLoadingTools: Bool = dataDownloader.started.value && tools.value.isEmpty
        isLoading.accept(value: isLoadingTools)
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
        
        //resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
