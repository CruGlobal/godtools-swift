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
    
    let resourcesService: ResourcesService
    let favoritedResourcesService: FavoritedResourcesService
    let languageSettingsService: LanguageSettingsService
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let toolListIsEditable: Bool = false
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, favoritedResourcesService: FavoritedResourcesService, languageSettingsService: LanguageSettingsService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.favoritedResourcesService = favoritedResourcesService
        self.languageSettingsService = languageSettingsService
        self.analytics = analytics
        
        super.init()
        
        reloadResourcesFromCache()
         
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        resourcesService.started.removeObserver(self)
        resourcesService.completed.removeObserver(self)
        favoritedResourcesService.resourceFavorited.removeObserver(self)
        favoritedResourcesService.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        resourcesService.started.addObserver(self) { [weak self] (started: Bool) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadIsLoading()
            }
        }
        
        resourcesService.completed.addObserver(self) { [weak self] (error: ResourcesServiceError?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadResourcesFromCache()
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
        
        let resourcesCache: RealmResourcesCache = resourcesService.realmResourcesCache
        
        resourcesCache.getResources(completeOnMain: { [weak self] (allResources: [ResourceModel]) in
            self?.tools.accept(value: allResources)
            self?.reloadIsLoading()
        })
    }
    
    private func reloadIsLoading() {
        
        let isLoadingTools: Bool = resourcesService.started.value && tools.value.isEmpty
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
        
        resourcesService.translationsServices.downloadAndCacheTranslations(resource: resource)
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
