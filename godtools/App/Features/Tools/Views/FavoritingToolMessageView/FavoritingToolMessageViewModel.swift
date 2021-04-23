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
    let hidesMessage: ObservableValue<AnimatableValue<Bool>> = ObservableValue(value: AnimatableValue(value: true, animated: false))
    
    required init(favoritingToolMessageCache: FavoritingToolMessageCache, localizationServices: LocalizationServices) {
        
        self.favoritingToolMessageCache = favoritingToolMessageCache
        self.localizationServices = localizationServices
        self.message = localizationServices.stringForMainBundle(key: "tool_offline_favorite_message")
        
        hidesMessage.accept(value: AnimatableValue(value: favoritingToolMessageCache.favoritingToolMessageDisabled, animated: false))
    }
    
    func closeTapped() {
        
        favoritingToolMessageCache.disableFavoritingToolMessage()
        hidesMessage.accept(value: AnimatableValue(value: true, animated: true))
    }
}
