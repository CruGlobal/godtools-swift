//
//  GetToolIsFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolIsFavoritedUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    @MainActor func execute(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Error> {
        
        return favoritedResourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .map { (favoritedResourcesChanged: Void) in
                
                return self.favoritedResourcesRepository
                    .getResourceIsFavorited(id: toolId)
            }
            .map { (isFavorited: Bool) in
                
                return ToolIsFavoritedDomainModel(
                    dataModelId: toolId,
                    isFavorited: isFavorited
                )
            }
            .eraseToAnyPublisher()
    }
}
