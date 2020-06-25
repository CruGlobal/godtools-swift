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
    let translateLanguageNameViewModel: TranslateLanguageNameViewModel
    let favoritedResourcesService: FavoritedResourcesService
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let toolListIsEditable: Bool = true
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    let findToolsTitle: String = "Find Tools"
    let hidesFindToolsView: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, translateLanguageNameViewModel: TranslateLanguageNameViewModel, favoritedResourcesService: FavoritedResourcesService, analytics: AnalyticsContainer) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.translateLanguageNameViewModel = translateLanguageNameViewModel
        self.favoritedResourcesService = favoritedResourcesService
        self.analytics = analytics
        
        super.init()
        
        reloadFavoritedResources()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        dataDownloader.completed.removeObserver(self)
        favoritedResourcesService.resourceFavorited.removeObserver(self)
        favoritedResourcesService.resourceUnfavorited.removeObserver(self)
        favoritedResourcesService.resourceSorted.removeObserver(self)
    }
    
    private func setupBinding() {
        
        dataDownloader.completed.addObserver(self) { [weak self] (result: Result<ResourcesDownloaderResult, ResourcesDownloaderError>?) in
            DispatchQueue.main.async { [weak self] in
                if result != nil {
                    self?.reloadFavoritedResources()
                }
            }
        }
        
        favoritedResourcesService.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavoritedResources()
        }
        
        favoritedResourcesService.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            self?.removeFavoritedResource(resourceIds: [resourceId])
        }
        
        favoritedResourcesService.resourceSorted.addObserver(self) { [weak self] (resourceId: String) in
            self?.reloadFavoritedResources()
        }
    }
    
    private func removeFavoritedResource(resourceIds: [String]) {
        removeTools(toolIdsToRemove: resourceIds)
        reloadHidesFindToolsView()
    }
    
    private func reloadFavoritedResources() {
        
        let resourcesCache: RealmResourcesCache = dataDownloader.resourcesCache
        let favoritedResourcesService: FavoritedResourcesService = self.favoritedResourcesService
        
        favoritedResourcesService.getFavoritedResources { (favoritedResources: [FavoritedResourceModel]) in
                        
            let sortedFavoritedResources: [FavoritedResourceModel] = favoritedResources.sorted(by: {$0.sortOrder < $1.sortOrder})
            let sortedFavoritedResourcesIds: [String] = sortedFavoritedResources.map({$0.resourceId})
            
            resourcesCache.getResources(resourceIds: sortedFavoritedResourcesIds) { [weak self] (resources: [ResourceModel]) in
                
                self?.tools.accept(value: resources)
                self?.reloadHidesFindToolsView()
            }
        }
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
            self?.favoritedResourcesService.removeFromFavorites(resourceId: resource.id)
        }
        flowDelegate?.navigate(step: .unfavoriteToolTappedFromFavoritedTools(resource: resource, removeHandler: removedHandler))
    }
    
    func didEditToolList(movedResource: ResourceModel, movedSourceIndexPath: IndexPath, toDestinationIndexPath: IndexPath) {
                
        if movedSourceIndexPath.row != toDestinationIndexPath.row {
            favoritedResourcesService.setSortOrder(resourceId: movedResource.id, sortOrder: toDestinationIndexPath.row)
        }
    }
}
