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
    let tools: ObservableValue<[RealmResource]> = ObservableValue(value: [])
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
            self?.reloadTools()
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTools()
        }
    }
    
    private func reloadResourcesFromCache() {
        
        let allResources: [RealmResource] = resourcesService.resourcesCache.realmCache.getResources()
        
        tools.accept(value: allResources)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Find Tools", siteSection: "tools", siteSubSection: "")
    }
    
    func toolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func aboutToolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolDetailsTappedFromAllTools(resource: resource))
    }
    
    func openToolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolTappedFromAllTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: RealmResource) {
        favoritedResourcesCache.changeFavorited(resourceId: resource.id)
    }
    
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // Do nothing because toolListIsEditable is currently set to false for all tools.
    }
}
