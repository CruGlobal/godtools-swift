//
//  ToolSpotlightViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 5/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolSpotlightViewModelDelegate: AnyObject {
    func spotlightToolCardTapped(resource: ResourceModel)
    func spotlightToolFavoriteButtonTapped(resource: ResourceModel)
}

class ToolSpotlightViewModel: ToolCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolSpotlightViewModelDelegate?
    
    // MARK: - Published
    
    @Published var spotlightTitle: String = ""
    @Published var spotlightSubtitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolSpotlightViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        self.delegate = delegate
        
        super.init()
        
        setTitleText()
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
        languageSettingsService.primaryLanguage.removeObserver(self)
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ToolDomainModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            tool: tool,
            dataDownloader: dataDownloader,
            languageSettingsService: languageSettingsService,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: self
        )
    }
}

// MARK: - Private

extension ToolSpotlightViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if cachedResourcesAvailable {
                    self.reloadResourcesFromCache()
                }
            }
        }
        
        dataDownloader.resourcesUpdatedFromRemoteDatabase.addObserver(self) { [weak self] (error: InitialDataDownloaderError?) in
            DispatchQueue.main.async { [weak self] in
                if error == nil {
                    self?.reloadResourcesFromCache()
                }
            }
        }
        
        languageSettingsService.primaryLanguage.addObserver(self) { [weak self] (primaryLanguage: LanguageModel?) in
            DispatchQueue.main.async { [weak self] in
                self?.setTitleText()
            }
        }
    }
    
    private func reloadResourcesFromCache() {
        
        // TODO: - use a use case here
        
        tools = dataDownloader.resourcesCache.getAllVisibleToolsSorted(andFilteredBy: { $0.attrSpotlight })
            .map({ resource in
                return ToolDomainModel(resource: resource)
            })
    }
    
    private func setTitleText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        spotlightTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.title")
        spotlightSubtitle = localizationServices.stringForBundle(bundle: languageBundle, key: "allTools.spotlight.description")
    }
}

// MARK: - ToolCardViewModelDelegate

extension ToolSpotlightViewModel: ToolCardViewModelDelegate {
    
    func toolCardTapped(_ tool: ToolDomainModel) {
        delegate?.spotlightToolCardTapped(resource: tool.resource)
    }
    
    func toolFavoriteButtonTapped(_ tool: ToolDomainModel) {
        delegate?.spotlightToolFavoriteButtonTapped(resource: tool.resource)
    }
    
    func toolDetailsButtonTapped(_ tool: ToolDomainModel) {}
    func openToolButtonTapped(_ tool: ToolDomainModel) {}
}
