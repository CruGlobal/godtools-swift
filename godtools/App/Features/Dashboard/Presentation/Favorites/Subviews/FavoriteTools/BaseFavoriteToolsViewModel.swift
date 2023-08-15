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
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var toolCardViewModelDelegate: ToolCardViewModelDelegate?
     
    let localizationServices: LocalizationServices
    
    let getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase
    let getBannerImageUseCase: GetBannerImageUseCase
    let getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase
    let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    let getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase
        
    @Published var viewState: ViewState = .loading
    @Published var sectionTitle: String = ""
        
    init(localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, toolCardViewModelDelegate: ToolCardViewModelDelegate?, maxNumberOfCardsToShow: Int?) {
        self.localizationServices = localizationServices
        
        self.getAllFavoritedToolsUseCase = getAllFavoritedToolsUseCase
        self.getBannerImageUseCase = getBannerImageUseCase
        self.getLanguageAvailabilityUseCase = getLanguageAvailabilityUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolIsFavoritedUseCase = getToolIsFavoritedUseCase
        
        self.toolCardViewModelDelegate = toolCardViewModelDelegate
        
        super.init(maxNumberOfCardsToShow: maxNumberOfCardsToShow)
        
        setupBinding()
    }
    
    // MARK: - Overrides
    
    override func cardViewModel(for tool: ToolDomainModel) -> BaseToolCardViewModel {
        return ToolCardViewModel(
            tool: tool,
            localizationServices: localizationServices,
            getBannerImageUseCase: getBannerImageUseCase,
            getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase,
            getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase,
            getToolIsFavoritedUseCase: getToolIsFavoritedUseCase,
            delegate: toolCardViewModelDelegate
        )
    }
    
    // MARK: - Public
    
    func setText(for language: LanguageDomainModel?) {
        
        sectionTitle = localizationServices.stringForLocaleElseSystemElseEnglish(localeIdentifier: language?.localeIdentifier, key: "favorites.favoriteTools.title")
    }
}

// MARK: - Private

extension BaseFavoriteToolsViewModel {
    private func setupBinding() {
        
        getAllFavoritedToolsUseCase.getAllFavoritedToolsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { favoritedTools in
                
                self.tools = favoritedTools
                self.viewState = favoritedTools.isEmpty ? .noTools : .tools
            }
            .store(in: &cancellables)
        
        getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            .receive(on: DispatchQueue.main)
            .sink { primaryLanguage in
                
                self.setText(for: primaryLanguage)
            }
            .store(in: &cancellables)
    }
}
