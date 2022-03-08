//
//  FavoritedToolsViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritedToolsViewModel: NSObject, FavoritedToolsViewModelType {
        
    private let getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase
    private let openTutorialCalloutCache: OpenTutorialCalloutCacheType
    
    private weak var flowDelegate: FlowDelegate?
    
    let dataDownloader: InitialDataDownloader
    let languageSettingsService: LanguageSettingsService
    let localizationServices: LocalizationServices
    let favoritedResourcesCache: FavoritedResourcesCache
    let deviceAttachmentBanners: DeviceAttachmentBanners
    let analytics: AnalyticsContainer
    let tools: ObservableValue<[ResourceModel]> = ObservableValue(value: [])
    let toolRefreshed: SignalValue<IndexPath> = SignalValue()
    let toolsRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    let toolListIsEditable: Bool = true
    let toolListIsEditing: ObservableValue<Bool> = ObservableValue(value: false)
    let findToolsTitle: String = "Find Tools"
    let hidesFindToolsView: ObservableValue<Bool> = ObservableValue(value: true)
    let isLoading: ObservableValue<Bool> = ObservableValue(value: false)
    let didEndRefreshing: Signal = Signal()
    
    required init(flowDelegate: FlowDelegate, dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, favoritedResourcesCache: FavoritedResourcesCache, deviceAttachmentBanners: DeviceAttachmentBanners, analytics: AnalyticsContainer, getTutorialIsAvailableUseCase: GetTutorialIsAvailableUseCase, openTutorialCalloutCache: OpenTutorialCalloutCacheType) {
        
        self.flowDelegate = flowDelegate
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.favoritedResourcesCache = favoritedResourcesCache
        self.deviceAttachmentBanners = deviceAttachmentBanners
        self.analytics = analytics
        self.getTutorialIsAvailableUseCase = getTutorialIsAvailableUseCase
        self.openTutorialCalloutCache = openTutorialCalloutCache
        
        super.init()
        
        reloadFavoritedResourcesFromCache()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        favoritedResourcesCache.resourceFavorited.removeObserver(self)
        favoritedResourcesCache.resourceUnfavorited.removeObserver(self)
        favoritedResourcesCache.resourceSorted.removeObserver(self)
    }
    
    var analyticsScreenName: String {
        return "Favorites"
    }
    
    private var analyticsSiteSection: String {
        return "tools"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    private func getFlowDelegate() -> FlowDelegate {
        guard let flowDelegate = self.flowDelegate else {
            assertionFailure("FlowDelegate should not be nil.")
            return self.flowDelegate!
        }
        return flowDelegate
    }
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                if !cachedResourcesAvailable {
                    self?.isLoading.accept(value: true)
                    self?.hidesFindToolsView.accept(value: true)
                }
                else {
                    self?.isLoading.accept(value: false)
                    self?.reloadFavoritedResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                self?.didEndRefreshing.accept()
                if error == nil {
                    self?.reloadFavoritedResourcesFromCache()
                }
            }
        }
        
        favoritedResourcesCache.resourceFavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.addFavoritedResource(resourceId: resourceId)
            }
        }
        
        favoritedResourcesCache.resourceUnfavorited.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.removeFavoritedResource(resourceIds: [resourceId])
            }
        }
        
        favoritedResourcesCache.resourceSorted.addObserver(self) { [weak self] (resourceId: String) in
            DispatchQueue.main.async { [weak self] in
                self?.reloadFavoritedResourcesFromCache()
            }
        }
    }
    
    private func addFavoritedResource(resourceId: String) {
        if let tool = dataDownloader.resourcesCache.getResource(id: resourceId) {
            addTool(tool: tool)
            hidesFindToolsView.accept(value: !tools.value.isEmpty)
        }
    }
    
    private func removeFavoritedResource(resourceIds: [String]) {
        removeTools(toolIdsToRemove: resourceIds)
        hidesFindToolsView.accept(value: !tools.value.isEmpty)
    }
    
    private func reloadFavoritedResourcesFromCache() {
        
        let sortedFavoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getSortedFavoritedResources()
        let sortedFavoritedResourcesIds: [String] = sortedFavoritedResources.map({$0.resourceId})
        
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getResources(resourceIds: sortedFavoritedResourcesIds)
        
        let filteredResources: [ResourceModel] = resources.filter({
            return !$0.isHidden
        })
        
        tools.accept(value: filteredResources)
        hidesFindToolsView.accept(value: !filteredResources.isEmpty)
        isLoading.accept(value: false)
    }
    
    func pageViewed() {
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: TrackScreenModel(screenName: analyticsScreenName, siteSection: analyticsSiteSection, siteSubSection: analyticsSiteSubSection))
    }
    
    func openTutorialWillAppear() -> OpenTutorialViewModelType {
        
        return OpenTutorialViewModel(
            flowDelegate: getFlowDelegate(),
            getTutorialIsAvailableUseCase: getTutorialIsAvailableUseCase,
            openTutorialCalloutCache: openTutorialCalloutCache,
            localizationServices: localizationServices,
            analytics: analytics
        )
    }
    
    func toolTapped(resource: ResourceModel) {
        trackToolTappedAnalytics()
        toolListIsEditing.accept(value: false)
        flowDelegate?.navigate(step: .toolTappedFromFavoritedTools(resource: resource))
    }
    
    func aboutToolTapped(resource: ResourceModel) {
        toolListIsEditing.accept(value: false)
        flowDelegate?.navigate(step: .aboutToolTappedFromFavoritedTools(resource: resource))
    }
    
    func openToolTapped(resource: ResourceModel) {
        trackOpenToolButtonAnalytics()
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
