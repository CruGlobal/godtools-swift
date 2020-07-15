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
    
    let message: String = "Make a tool available offline by tapping the heart icon which adds it to your favorites."
    let hidesMessage: ObservableValue<(hidden: Bool, animated: Bool)> = ObservableValue(value: (hidden: false, animated: false))
    
    required init(favoritingToolMessageCache: FavoritingToolMessageCache) {
        
        self.favoritingToolMessageCache = favoritingToolMessageCache
        
        hidesMessage.accept(value: (hidden: favoritingToolMessageCache.favoritingToolMessageDisabled, animated: false))
    }
    
    func closeTapped() {
        
        favoritingToolMessageCache.disableFavoritingToolMessage()
    }
}
