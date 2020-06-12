//
//  AllToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class AllToolsViewModel: NSObject, AllToolsViewModelType {
    
    private let resourcesDownloaderAndCache: ResourcesDownloaderAndCache
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let tools: ObservableValue<[RealmResource]> = ObservableValue(value: [])
    let message: ObservableValue<String> = ObservableValue(value: "")
    let toolListIsEditable: Bool = false
    
    required init(flowDelegate: FlowDelegate, resourcesDownloaderAndCache: ResourcesDownloaderAndCache, favoritedResourcesCache: RealmFavoritedResourcesCache, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesDownloaderAndCache = resourcesDownloaderAndCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        
        super.init()
        
        reloadResourcesFromCache()
         
        if let downloadResourcesReceipt = resourcesDownloaderAndCache.currentRequestReceipt {
            downloadResourcesReceipt.addCompletedObserver(observer: self, onObserve: { [weak self] (error: ResourcesDownloaderAndCacheError?) in
                DispatchQueue.main.async { [weak self] in
                    self?.reloadResourcesFromCache()
                }
            })
        }
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
    }
    
    private func setupBinding() {
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTools()
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadTools()
        }
    }
    
    private func reloadResourcesFromCache() {
        
        let allResources: [RealmResource] = resourcesDownloaderAndCache.realmCache.getResources()
        
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
