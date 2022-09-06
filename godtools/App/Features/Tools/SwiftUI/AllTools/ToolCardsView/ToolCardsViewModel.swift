//
//  ToolCardsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/6/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol ToolCardsViewModelDelegate: ToolCardViewModelDelegate {
    func toolsAreLoading(_ isLoading: Bool)
}

class ToolCardsViewModel: ToolCardProvider {
    
    // MARK: - Properties
    
    private let dataDownloader: InitialDataDownloader
    private let languageSettingsService: LanguageSettingsService
    private let localizationServices: LocalizationServices
    
    private let getBannerImageUseCase: GetBannerImageUseCase
    private let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    private let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    private weak var delegate: ToolCardsViewModelDelegate?
    
    private var categoryFilterValue: String?
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getBannerImageUseCase: GetBannerImageUseCase,  getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: ToolCardsViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.delegate = delegate
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
        dataDownloader.resourcesUpdatedFromRemoteDatabase.removeObserver(self)
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
            delegate: delegate
        )
    }
    
    override func toolTapped(_ tool: ToolDomainModel) {
        delegate?.toolCardTapped(tool)
    }
}

// MARK: - Private

extension ToolCardsViewModel {
    
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.toolsAreLoading(!cachedResourcesAvailable)
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
    }
    
    private func reloadResourcesFromCache() {
        
        if let categoryFilterValue = categoryFilterValue {
            tools = dataDownloader.resourcesCache.getAllVisibleToolsSorted(andFilteredBy: { $0.attrCategory == categoryFilterValue })
                .map({ resource in
                    return ToolDomainModel(resource: resource)
                })
            
        } else {
            tools = dataDownloader.resourcesCache.getAllVisibleToolsSorted()
                .map({ resource in
                    return ToolDomainModel(resource: resource)
                })
        }
        
        self.delegate?.toolsAreLoading(false)
    }
}

// MARK: - Public

extension ToolCardsViewModel {
    
    func filterTools(with attrCategory: String?) {
        categoryFilterValue = attrCategory
        reloadResourcesFromCache()
    }
}
