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
    
    private let maxNumberCardsShown = 3
    
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
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: FavoriteToolsViewModelDelegate?) {
        
        super.init(cardType: .squareWithNavButtons, dataDownloader: dataDownloader, deviceAttachmentBanners: deviceAttachmentBanners, favoritedResourcesCache: favoritedResourcesCache, languageSettingsService: languageSettingsService, localizationServices: localizationServices, delegate: delegate, toolCardViewModelDelegate: delegate)
        
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
