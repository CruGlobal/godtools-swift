//
//  ToggleToolFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class ToggleToolFavoritedUseCase: Sendable {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String) async throws -> ToolIsFavoritedDomainModel {
        
        let resourceIsFavorited: Bool = favoritedResourcesRepository.getResourceIsFavorited(
            id: toolId
        )
        
        let isFavorited: Bool
        
        if resourceIsFavorited {
            
            _ = try await favoritedResourcesRepository
                .deleteFavoritedResource(id: toolId)
            
            isFavorited = false
        }
        else {
            
            _ = try await favoritedResourcesRepository
                .storeFavoritedResources(ids: [toolId])
            
            isFavorited = true
        }
        
        return ToolIsFavoritedDomainModel(
            dataModelId: toolId,
            isFavorited: isFavorited
        )
    }
}
