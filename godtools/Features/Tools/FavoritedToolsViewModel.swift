//
//  FavoritedToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedToolsViewModel: NSObject, FavoritedToolsViewModelType {
    
    private let analytics: AnalyticsContainer
    
    private weak var flowDelegate: FlowDelegate?
    
    let resourcesService: ResourcesService
    let favoritedResourcesCache: RealmFavoritedResourcesCache
    let languageSettingsCache: LanguageSettingsCacheType
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let toolListIsEditable: Bool = true
    let findToolsTitle: String = "Find Tools"
    let hidesFindToolsView: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(flowDelegate: FlowDelegate, resourcesService: ResourcesService, favoritedResourcesCache: RealmFavoritedResourcesCache, languageSettingsCache: LanguageSettingsCacheType, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.resourcesService = resourcesService
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsCache = languageSettingsCache
        self.analytics = analytics
        
        super.init()
        
        reloadFavoritedResourcesFromCache()
        
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
                self?.reloadFavoritedResourcesFromCache()
            }
        }
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavoritedResourcesFromCache()
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.removeTools(toolIdsToRemove: [resourceId])
            self?.reloadHidesFindToolsView()
        }
    }
    
    private func reloadFavoritedResourcesFromCache() {
        
        let resourcesCache: RealmResourcesCache = resourcesService.realmResourcesCache
        let favoritedResourcesCache: RealmFavoritedResourcesCache = self.favoritedResourcesCache
        
        resourcesCache.getResources(completeOnMain: { [weak self] (allResources: [ResourceModel]) in

            favoritedResourcesCache.getFavoritedResources(completeOnMain: { [weak self] (allFavoritedResources: [FavoritedResourceModel]) in
            
                    let favoritedResourcesIds: [String] = allFavoritedResources.map({$0.resourceId})
                    let favoritedResources: [ResourceModel] = allResources.filter({favoritedResourcesIds.contains($0.id)})
                    
                    self?.tools.accept(value: favoritedResources)
                    self?.reloadHidesFindToolsView()
                })
        })
    }
    
    private func reloadHidesFindToolsView() {
        hidesFindToolsView.accept(value: !tools.value.isEmpty)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
    
    func toolTapped(resource: ResourceModel) {
        //flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func aboutToolTapped(resource: ResourceModel) {
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolTapped(resource: ResourceModel) {
        //flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: ResourceModel) {
        
        let removedHandler = CallbackHandler { [weak self] in
            self?.favoritedResourcesCache.removeResourceFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func didEditToolList(movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
        // TODO: Update sort order for favorited resources. ~Levi
        print("\n Favorited Tools - Did Edit Tools List")
        print("  movedSourceIndexPath: \(movedSourceIndexPath.row)")
        print("  toDestinationIndexPath: \(toDestinationIndexPath.row)")
    }
}
