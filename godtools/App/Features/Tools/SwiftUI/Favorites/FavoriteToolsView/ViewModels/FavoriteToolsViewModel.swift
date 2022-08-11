//
//  FavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol FavoriteToolsViewModelDelegate: ToolCardViewModelDelegate, BaseFavoriteToolsViewModelDelegate {
    func viewAllFavoriteToolsButtonTapped()
    func goToToolsButtonTapped()
}

class FavoriteToolsViewModel: BaseFavoriteToolsViewModel {
 
    // MARK: - Constants
    
    private let maxNumberCardsShown = 5
    
    // MARK: - Properties
    
    private var favoriteToolsViewModelDelegate: FavoriteToolsViewModelDelegate? {
        return delegate as? FavoriteToolsViewModelDelegate
    }
    
    // MARK: - Published
    
    @Published var viewAllButtonText: String = ""
    @Published var noFavoriteToolsTitle: String = ""
    @Published var noFavoriteToolsDescription: String = ""
    @Published var noFavoriteToolsButtonText: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, getAllFavoritedToolsUseCase: GetAllFavoritedToolsUseCase, getBannerImageUseCase: GetBannerImageUseCase, getFavoritedResourcesChangedUseCase: GetFavoritedResourcesChangedUseCase, getLanguageAvailabilityStringUseCase: GetLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: GetToolIsFavoritedUseCase, delegate: FavoriteToolsViewModelDelegate?) {
        
        super.init(dataDownloader: dataDownloader, favoritedResourcesCache: favoritedResourcesCache, languageSettingsService: languageSettingsService, localizationServices: localizationServices, getAllFavoritedToolsUseCase: getAllFavoritedToolsUseCase, getBannerImageUseCase: getBannerImageUseCase, getFavoritedResourcesChangedUseCase: getFavoritedResourcesChangedUseCase, getLanguageAvailabilityStringUseCase: getLanguageAvailabilityStringUseCase, getToolIsFavoritedUseCase: getToolIsFavoritedUseCase, delegate: delegate, toolCardViewModelDelegate: delegate)
        
        maxNumberCardsToShow = maxNumberCardsShown
    }
    
    override func setText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        
        viewAllButtonText = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteTools.viewAll") + " >"
        noFavoriteToolsTitle = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.noTools.title")
        noFavoriteToolsDescription = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.noTools.description")
        noFavoriteToolsButtonText = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.noTools.button")
        
        super.setText()
    }
}

// MARK: - Public

extension FavoriteToolsViewModel {
    func viewAllButtonTapped() {
        favoriteToolsViewModelDelegate?.viewAllFavoriteToolsButtonTapped()
    }
    
    func goToToolsButtonTapped() {
        favoriteToolsViewModelDelegate?.goToToolsButtonTapped()
    }
}
