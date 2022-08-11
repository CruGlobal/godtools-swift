//
//  BaseFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

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
    let getFavoritedResourcesChangedUseCase: GetFavoritedResourcesChangedUseCase
    let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    weak var delegate: BaseFavoriteToolsViewModelDelegate?
    weak var toolCardViewModelDelegate: ToolCardViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getFavoritedResourcesChangedUseCase: GetFavoritedResourcesChangedUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: BaseFavoriteToolsViewModelDelegate?, toolCardViewModelDelegate: ToolCardViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.favoritedResourcesCache = favoritedResourcesCache
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getFavoritedResourcesChangedUseCase = getFavoritedResourcesChangedUseCase
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
        // TODO: - fix this
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
        
        getFavoritedResourcesChangedUseCase.getFavoritedResourcesChanged()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.reloadFavoritedResourcesFromCache()
            }
            .store(in: &cancellables)
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setText()
            }
        }
    }
    
    private func reloadFavoritedResourcesFromCache() {
        
        let sortedFavoritedResources: [FavoritedResourceModel] = favoritedResourcesCache.getSortedFavoritedResources()
        let sortedFavoritedResourcesIds: [String] = sortedFavoritedResources.map({$0.resourceId})
        
        let resources: [ResourceModel] = dataDownloader.resourcesCache.getResources(resourceIds: sortedFavoritedResourcesIds)
        
        let filteredResources: [ResourceModel] = resources.filter({
            return !$0.isHidden
        })
        
        withAnimation {
            tools = filteredResources
        }
        self.delegate?.toolsAreLoading(false)
    }
}
