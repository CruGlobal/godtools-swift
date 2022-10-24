//
//  FavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol FavoriteToolsViewModelDelegate: ToolCardViewModelDelegate {
    func viewAllFavoriteToolsButtonTapped()
    func goToToolsButtonTapped()
}

class FavoriteToolsViewModel: BaseFavoriteToolsViewModel {
 
    // MARK: - Constants
    
    private let maxNumberCardsShown = 5
    
    // MARK: - Properties
    
    private weak var delegate: FavoriteToolsViewModelDelegate?
    
    // MARK: - Published
    
    @Published var viewAllButtonText: String = ""
    @Published var noFavoriteToolsTitle: String = ""
    @Published var noFavoriteToolsDescription: String = ""
    @Published var noFavoriteToolsButtonText: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getLanguageAvailabilityUseCase: GetLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: FavoriteToolsViewModelDelegate?) {
        
        self.delegate = delegate
        
        super.init(dataDownloader: dataDownloader, localizationServices: localizationServices, getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase, getBannerImageUseCase: getBannerImageUseCase, getLanguageAvailabilityUseCase: getLanguageAvailabilityUseCase, getSettingsParallelLanguageUseCase: getSettingsParallelLanguageUseCase, getSettingsPrimaryLanguageUseCase: getSettingsPrimaryLanguageUseCase, getToolIsFavoritedUseCase: getToolIsFavoritedUseCase, toolCardViewModelDelegate: delegate)
        
        maxNumberCardsToShow = maxNumberCardsShown
    }
    
    override func setText(for language: LanguageDomainModel?) {
        
        viewAllButtonText = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "favorites.favoriteTools.viewAll") + " >"
        noFavoriteToolsTitle = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "favorites.noTools.title")
        noFavoriteToolsDescription = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "favorites.noTools.description")
        noFavoriteToolsButtonText = localizationServices.stringForLocaleElseSystem(localeIdentifier: language?.localeIdentifier, key: "favorites.noTools.button")
        
        super.setText(for: language)
    }
}

// MARK: - Public

extension FavoriteToolsViewModel {
    func viewAllButtonTapped() {
        delegate?.viewAllFavoriteToolsButtonTapped()
    }
    
    func goToToolsButtonTapped() {
        delegate?.goToToolsButtonTapped()
    }
}
