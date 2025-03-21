//
//  ReorderFavoritedToolRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 3/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class ReorderFavoritedToolRepository: ReorderFavoritedToolRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func reorderFavoritedToolPubilsher(toolId: String, originalPosition: Int, newPosition: Int) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return favoritedResourcesRepository.reorderFavoritedResourcePublisher(id: toolId, originalPosition: originalPosition, newPosition: newPosition)
    }
}
