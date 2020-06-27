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
    let resourcesTranslationsDownloader: ResourcesTranslationsDownloader
    let languageSettingsService: LanguageSettingsService
    let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    let favoritedResourcesService: FavoritedResourcesService
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let toolListIsEditable: Bool = false
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, resourcesTranslationsDownloader: ResourcesTranslationsDownloader, languageSettingsService: LanguageSettingsService, translateLanguageNameViewModel: TranslateLanguageNameViewModel, favoritedResourcesService: FavoritedResourcesService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.resourcesTranslationsDownloader = resourcesTranslationsDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = translateLanguageNameViewModel
        self.favoritedResourcesService = favoritedResourcesService
        self.analytics = analytics
        
        super.init()
        
        reloadResourcesFromCache()
         
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.started.removeObserver(self)
        dataDownloader.completed.removeObserver(self)
        favoritedResourcesService.resourceFavorited.removeObserver(self)
        favoritedResourcesService.resourceUnfavorited.removeObserver(self)
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
        
        favoritedResourcesService.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTool(resourceId: resourceId)
        }
        
        favoritedResourcesService.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTool(resourceId: resourceId)
        }
    }
    
    private func reloadResourcesFromCache() {
                
        dataDownloader.resourcesCache.getResources(completeOnMain: { [weak self] (allResources: [ResourceModel]) in
            self?.tools.accept(value: allResources)
            self?.reloadIsLoading()
        })
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
        
        favoritedResourcesService.toggleFavorited(resourceId: resource.id)
        
        //resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
