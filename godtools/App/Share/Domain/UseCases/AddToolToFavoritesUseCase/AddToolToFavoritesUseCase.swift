//
//  AddToolToFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AddToolToFavoritesUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
     
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func addToolToFavorites(resourceId: String) {
        
        _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: resourceId)
    }
}
