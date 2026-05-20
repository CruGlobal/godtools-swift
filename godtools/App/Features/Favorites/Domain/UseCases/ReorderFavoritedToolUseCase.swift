//
//  ReorderFavoritedToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

final class ReorderFavoritedToolUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String, originalPosition: Int, newPosition: Int) async throws -> [ReorderFavoritedToolDomainModel] {
        
        let favoritesReordered: [FavoritedResourceDataModel] = try await favoritedResourcesRepository
            .reorderFavoritedResource(
                id: toolId,
                originalPosition: originalPosition,
                newPosition: newPosition
            )
        
        return favoritesReordered.map {
            ReorderFavoritedToolDomainModel(dataModelId: $0.id, position: $0.position)
        }
    }
}
