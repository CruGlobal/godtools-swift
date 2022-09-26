//
//  BaseFavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/23/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI
import Combine

class BaseFavoriteToolsViewModel: ToolCardProvider {
    
    enum ViewState {
        case loading
        case noTools
        case tools
    }
 
    // MARK: - Properties
    
    let dataDownloader: InitialDataDownloader
    let localizationServices: LocalizationServices
    
    let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    let getBannerImageUseCase: GetBannerImageUseCase
    let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
    
    weak var toolCardViewModelDelegate: ToolCardViewModelDelegate?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published
    
    @Published var viewState: ViewState = .loading
    @Published var sectionTitle: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toolCardViewModelDelegate: ToolCardViewModelDelegate?) {
        self.dataDownloader = dataDownloader
        self.localizationServices = localizationServices
        
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.toolCardViewModelDelegate = toolCardViewModelDelegate
        
        super.init()
        
        setupBinding()
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ToolDomainModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            tool: tool,
            dataDownloader: dataDownloader,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
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
        
        getAllFavoritedToolsUseCase.getAllFavoritedToolsPublisher()
            .receiveOnMain()
            .sink { favoritedTools in
                
                self.tools = favoritedTools
                self.viewState = favoritedTools.isEmpty ? .noTools : .tools
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
