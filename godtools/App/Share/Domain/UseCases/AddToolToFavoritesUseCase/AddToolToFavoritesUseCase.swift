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
    
    // TODO: Replace ResourceModel with ToolDomainModel when GT-1742 is implemented. ~Levi
    func addToolToFavorites(resource: ResourceModel) {
        
        favoritedResourcesRepository.store(resourceId: resource.id)
    }
}
