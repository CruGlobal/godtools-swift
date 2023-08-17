//
//  RemoveToolFromFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class RemoveToolFromFavoritesUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func removeToolFromFavorites(id: String) {
        
        _ = favoritedResourcesRepository.deleteFavoritedResource(resourceId: id)
    }
}
