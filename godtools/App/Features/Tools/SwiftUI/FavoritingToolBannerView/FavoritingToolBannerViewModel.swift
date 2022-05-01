//
//  FavoritingToolBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class FavoritingToolBannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let localizationServices: LocalizationServices
    
    // MARK: - Published
    
    @Published var message: String
    
    // MARK: - Init
    
    init(favoritingToolMessageCache: FavoritingToolMessageCache, localizationServices: LocalizationServices) {
        
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.localizationServices = localizationServices
        
        message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
    }
}
