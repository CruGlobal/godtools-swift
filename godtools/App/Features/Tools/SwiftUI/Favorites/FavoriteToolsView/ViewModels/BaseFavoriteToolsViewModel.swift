//
//  BaseFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

protocol BaseFavoriteToolsViewModelDelegate: AnyObject {
    func toolsAreLoading(_ isLoading: Bool)
}

class BaseFavoriteToolsViewModel: ToolCardProvider {
 
    // MARK: - Properties
    
    let dataDownloader: InitialDataDownloader
    let favoritedResourcesCache: FavoritedResourcesCache
    let languageSettingsService: LanguageSettingsService
    let localizationServices: LocalizationServices
    
    let getBannerImageUseCase: GetBannerImageUseCase
    let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    weak var delegate: BaseFavoriteToolsViewModelDelegate?
    weak var toolCardViewModelDelegate: ToolCardViewModelDelegate?
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: BaseFavoriteToolsViewModelDelegate?, toolCardViewModelDelegate: ToolCardViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.delegate = delegate
        self.toolCardViewModelDelegate = toolCardViewModelDelegate
        
        super.init()
        
        reloadFavoritedResourcesFromCache()
        setupBinding()
        setText()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ResourceModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            resource: tool,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: toolCardViewModelDelegate
        )
    }
    
    // MARK: - Public
    
    func setText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteTools.title")
    }
    
    func removeFavoritedResource(resourceIds: [String]) {
        removeTools(toolIdsToRemove: resourceIds)
    }
}

// MARK: - Private

extension BaseFavoriteToolsViewModel {
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.toolsAreLoading(!cachedResourcesAvailable)
                if cachedResourcesAvailable {
                    self.reloadFavoritedResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
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
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setText()
            }
        }
    }
    
    private func addTool(tool: ResourceModel) {
        
        var updatedToolsList: [ResourceModel] = tools
        
        guard !updatedToolsList.contains(tool) else {
            return
        }
        
        updatedToolsList.insert(tool, at: 0)
        tools = updatedToolsList
    }

    private func removeTools(toolIdsToRemove: [String]) {
        let toolsToRemove: [ResourceModel] = tools.filter({toolIdsToRemove.contains($0.id)})
        removeTools(toolsToRemove: toolsToRemove)
    }
    
    func removeTools(toolsToRemove: [ResourceModel]) {
        
        guard !tools.isEmpty && !toolsToRemove.isEmpty else {
            return
        }
        
        var updatedToolsList: [ResourceModel] = tools
        var removedIndexPaths: [IndexPath] = Array()
        
        for toolToRemove in toolsToRemove {
            if let index = updatedToolsList.firstIndex(of: toolToRemove) {
                removedIndexPaths.append(IndexPath(row: index, section: 0))
                updatedToolsList.remove(at: index)
            }
        }
        
        withAnimation {
            tools = updatedToolsList
        }
    }
    
    private func addFavoritedResource(resourceId: String) {
        if let tool = dataDownloader.resourcesCache.getResource(id: resourceId) {
            addTool(tool: tool)
        }
    }
    
    private func reloadFavoritedResourcesFromCache() {
        
        let sortedFavoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getSortedFavoritedResources()
        let sortedFavoritedResourcesIds: [String] = sortedFavoritedResources.map({$0.resourceId})
        
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getResources(resourceIds: sortedFavoritedResourcesIds)
        
        let filteredResources: [ResourceModel] = resources.filter({
            return !$0.isHidden
        })
        
        tools = filteredResources
        self.delegate?.toolsAreLoading(false)
    }
}
