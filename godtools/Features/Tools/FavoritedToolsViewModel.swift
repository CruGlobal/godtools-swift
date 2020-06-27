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
    
    let dataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let favoritedResourcesCache: FavoritedResourcesCache
    let fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let toolListIsEditable: Bool = true
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    let findToolsTitle: String = "Find Tools"
    let hidesFindToolsView: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, favoritedResourcesCache: FavoritedResourcesCache, fetchLanguageTranslationViewModel: FetchLanguageTranslationViewModel, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.favoritedResourcesCache = favoritedResourcesCache
        self.fetchLanguageTranslationViewModel = fetchLanguageTranslationViewModel
        self.analytics = analytics
        
        super.init()
        
        reloadFavoritedResources()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        dataDownloader.completed.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
        favoritedResourcesCache.resourceSorted.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.completed.addObserver(self) { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>?) in
            DispatchQueue.main.async { [weak self] in
                if result != nil {
                    self?.reloadFavoritedResources()
                }
            }
        }
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavoritedResources()
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.removeFavoritedResource(resourceIds: [resourceId])
            }
        }
        
        favoritedResourcesCache.resourceSorted.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavoritedResources()
            }
        }
    }
    
    private func removeFavoritedResource(resourceIds: [String]) {
        removeTools(toolIdsToRemove: resourceIds)
        reloadHidesFindToolsView()
    }
    
    private func reloadFavoritedResources() {
        
        let favoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getFavoritedResources()
        let sortedFavoritedResources: [FavoritedResourceModel] = favoritedResources.sorted(by: {$0.sortOrder < $1.sortOrder})
        let sortedFavoritedResourcesIds: [String] = sortedFavoritedResources.map({$0.resourceId})
        
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getResources(resourceIds: sortedFavoritedResourcesIds)
        
        tools.accept(value: resources)
        reloadHidesFindToolsView()
    }
    
    private func reloadHidesFindToolsView() {
        hidesFindToolsView.accept(value: !tools.value.isEmpty)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(screenName: "Home", siteSection: "", siteSubSection: "")
    }
    
    func toolTapped(resource: ResourceModel) {
        toolListIsEditing.accept(value: false)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func aboutToolTapped(resource: ResourceModel) {
        toolListIsEditing.accept(value: false)
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolTapped(resource: ResourceModel) {
        toolListIsEditing.accept(value: false)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func favoriteToolTapped(resource: ResourceModel) {
        
        toolListIsEditing.accept(value: false)
        
        let removedHandler = CallbackHandler { [weak self] in
            self?.favoritedResourcesCache.removeFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
                
        if movedSourceIndexPath.row != toDestinationIndexPath.row {
            favoritedResourcesCache.setSortOrder(resourceId: movedResource.id, newSortOrder: toDestinationIndexPath.row)
        }
    }
}
