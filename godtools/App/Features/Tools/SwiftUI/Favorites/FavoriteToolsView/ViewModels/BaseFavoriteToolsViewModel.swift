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
    let languageSettingsService: LanguageSettingsService
    let localizationServices: LocalizationServices
    
    let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    let getBannerImageUseCase: GetBannerImageUseCase
    let getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase
    let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    weak var delegate: BaseFavoriteToolsViewModelDelegate?
    weak var toolCardViewModelDelegate: ToolCardViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var sectionTitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: BaseFavoriteToolsViewModelDelegate?, toolCardViewModelDelegate: ToolCardViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.languageSettingsService = languageSettingsService
        self.localizationServices = localizationServices
        
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityStringUseCase = getLanguageAvailabilityStringUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.delegate = delegate
        self.toolCardViewModelDelegate = toolCardViewModelDelegate
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        dataDownloader.cachedResourcesAvailable.removeObserver(self)
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
            delegate: toolCardViewModelDelegate
        )
    }
    
    // MARK: - Public
    
    func setText(for languageBundle: Bundle) {
        
        sectionTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteTools.title")
    }
}

// MARK: - Private

extension BaseFavoriteToolsViewModel {
    private func setupBinding() {
        
        dataDownloader.cachedResourcesAvailable.addObserver(self) { [weak self] (cachedResourcesAvailable: Bool) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.toolsAreLoading(!cachedResourcesAvailable)
            }
        }
        
        getAllFavoritedToolsUseCase.getAllFavoritedToolsPublisher()
            .receiveOnMain()
            .sink { favoritedTools in
                
                withAnimation {
                    self.tools = favoritedTools
                }
                self.delegate?.toolsAreLoading(false)
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receiveOnMain()
            .sink { primaryLanguage in
                
                guard let primaryLanguage = primaryLanguage,
                      let languageBundle = self.localizationServices.bundleLoader.bundleForResource(resourceName: primaryLanguage.localeIdentifier)
                else { return }
                
                self.setText(for: languageBundle)
            }
            .store(in: &cancellables)
    }
}
