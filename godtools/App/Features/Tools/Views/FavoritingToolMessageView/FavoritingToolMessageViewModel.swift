//
//  FavoritingToolMessageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FavoritingToolMessageViewModel: FavoritingToolMessageViewModelType {
    
    private let favoritingToolMessageCache: FavoritingToolMessageCache
    private let localizationServices: LocalizationServices
    
    let message: String
    let hidesMessage: ObservableValue<(hidden: Bool, animated: Bool)> = ObservableValue(value: (hidden: false, animated: false))
    
    required init(favoritingToolMessageCache: FavoritingToolMessageCache, localizationServices: LocalizationServices) {
        
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.localizationServices = localizationServices
        self.message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
        
        hidesMessage.accept(value: (hidden: favoritingToolMessageCache.favoritingToolMessageDisabled, animated: false))
    }
    
    func closeTapped() {
        
        favoritingToolMessageCache.disableFavoritingToolMessage()
        hidesMessage.accept(value: (hidden: true, animated: true))
    }
}
