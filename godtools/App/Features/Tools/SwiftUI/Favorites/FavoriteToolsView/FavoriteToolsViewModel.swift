//
//  FavoriteToolsViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

protocol FavoriteToolsViewModelDelegate: ToolCardDelegate {
    func viewAllFavoriteToolsButtonTapped()
}

class FavoriteToolsViewModel: BaseFavoriteToolsViewModel {
 
    // MARK: - Properties
    private var favoriteToolsViewModelDelegate: FavoriteToolsViewModelDelegate? {
        return delegate as? FavoriteToolsViewModelDelegate
    }
    
    // MARK: - Published
    
    @Published var viewAllButtonText: String = ""
    
    // MARK: - Init
    
    init(dataDownloader: InitialDataDownloader, deviceAttachmentBanners: DeviceAttachmentBanners, favoritedResourcesCache: FavoritedResourcesCache, languageSettingsService: LanguageSettingsService, localizationServices: LocalizationServices, delegate: FavoriteToolsViewModelDelegate?) {
        
        super.init(cardType: .squareWithNavButtons, dataDownloader: dataDownloader, deviceAttachmentBanners: deviceAttachmentBanners, favoritedResourcesCache: favoritedResourcesCache, languageSettingsService: languageSettingsService, localizationServices: localizationServices, delegate: delegate)
    }
    
    override func setText() {
        let languageBundle = localizationServices.bundleLoader.bundleForPrimaryLanguageOrFallback(in: languageSettingsService)
        viewAllButtonText = localizationServices.stringForBundle(bundle: languageBundle, key: "favorites.favoriteTools.viewAll") + " >"
        
        super.setText()
    }
}

// MARK: - Public

extension FavoriteToolsViewModel {
    func viewAllButtonTapped() {
        favoriteToolsViewModelDelegate?.viewAllFavoriteToolsButtonTapped()
    }
}
