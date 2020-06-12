//
//  FavoritedToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedToolsViewModel: NSObject, FavoritedToolsViewModelType {
    
    private let resourcesDownloaderAndCache: ResourcesDownloaderAndCache
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let tools: ObservableValue<[RealmResource]> = ObservableValue(value: [])
    let toolListIsEditable: Bool = true
    let findToolsTitle: String = "Find Tools"
    let hidesFindToolsView: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(flowDelegate: FlowDelegate, resourcesDownloaderAndCache: ResourcesDownloaderAndCache, favoritedResourcesCache: RealmFavoritedResourcesCache, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesDownloaderAndCache = resourcesDownloaderAndCache
        self.favoritedResourcesCache = favoritedResourcesCache
        self.analytics = analytics
        
        super.init()
        
        reloadFavoritedResourcesFromCache()
        
       if let downloadResourcesReceipt = resourcesDownloaderAndCache.currentRequestReceipt {
           downloadResourcesReceipt.addCompletedObserver(observer: self, onObserve: { [weak self] (error: ResourcesDownloaderAndCacheError?) in
               DispatchQueue.main.async { [weak self] in
                   self?.reloadFavoritedResourcesFromCache()
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
            self?.reloadFavoritedResourcesFromCache()
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavoritedResourcesFromCache()
        }
    }
    
    private func reloadFavoritedResourcesFromCache() {
        
        let allResources: [RealmResource] = resourcesDownloaderAndCache.realmCache.getResources()
        
        let cachedFavoritedResources: [RealmFavoritedResource] = favoritedResourcesCache.getCachedFavoritedResources()
        let cachedFavoritedResourcesIds: [String] = cachedFavoritedResources.map({$0.resourceId})
        
        let favoritedResources: [RealmResource] = allResources.filter({cachedFavoritedResourcesIds.contains($0.id)})
        
        if favoritedResources.isEmpty {
            hidesFindToolsView.accept(value: false)
        }
        else {
            hidesFindToolsView.accept(value: true)
            tools.accept(value: favoritedResources)
        }
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
    
    func toolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func aboutToolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolDetailsTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolTapped(resource: RealmResource) {
        //flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: RealmResource) {
        favoritedResourcesCache.changeFavorited(resourceId: resource.id)
    }
    
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // TODO: Update sort order for favorited resources. ~Levi
        print("\n Favorited Tools - Did Edit Tools List")
        print("  movedSourceIndexPath: \(movedSourceIndexPath.row)")
        print("  toDestinationIndexPath: \(toDestinationIndexPath.row)")
    }
}
