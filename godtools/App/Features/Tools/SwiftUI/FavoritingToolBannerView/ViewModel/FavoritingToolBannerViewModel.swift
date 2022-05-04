//
//  FavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class FavoritingToolBannerViewModel: BaseFavoritingToolBannerViewModel {
    
    // MARK: - Properties
    
    private let localizationServices: LocalizationServices
    
    // MARK: - Init
    
    init(favoritingToolMessageCache: FavoritingToolMessageCache, localizationServices: LocalizationServices, delegate: FavoritingToolBannerDelegate?) {
        self.localizationServices = localizationServices
        
        let message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
        
        super.init(message: message, delegate: delegate)
    }
    
    // MARK: - Public
    
    override func closeTapped() {
        delegate?.closeBanner()
    }
}
