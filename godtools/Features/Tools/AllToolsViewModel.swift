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
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let languageSettingsCache: LanguageSettingsCacheType
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let message: ObservableValue<String> = ObservableValue(value: "")
    let toolListIsEditable: Bool = false
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsCache = languageSettingsCache
        self.analytics = analytics
        
        super.init()
        
        reloadResourcesFromCache()
         
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        resourcesService.completed.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        resourcesService.completed.addObserver(self) { [weak self] (error: ResourcesServiceError?) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadResourcesFromCache()
            }
        }
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTool(resourceId: resourceId)
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTool(resourceId: resourceId)
        }
    }
    
    private func reloadResourcesFromCache() {
        resourcesService.realmResourcesCache.getResources { [weak self] (allResources: [ResourceModel]) in
            self?.tools.accept(value: allResources)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func toolTapped(resource: ResourceModel) {
        //flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func aboutToolTapped(resource: ResourceModel) {
        //flowDelegate?.navigate(step: .toolDetailsTappedFromAllTools(resource: resource))
    }
    
    func openToolTapped(resource: ResourceModel) {
        //flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: ResourceModel) {
        favoritedResourcesCache.toggleFavorited(resourceId: resource.id)
    }
    
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
