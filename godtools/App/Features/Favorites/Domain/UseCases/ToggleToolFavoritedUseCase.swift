//
//  ToggleToolFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class ToggleToolFavoritedUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Error> {
        
        let resourceIsFavorited: Bool = favoritedResourcesRepository.getResourceIsFavorited(id: toolId)
        
        if resourceIsFavorited {
            
            return favoritedResourcesRepository
                .deleteFavoritedResourcePublisher(id: toolId)
                .map { _ in
                    ToolIsFavoritedDomainModel(dataModelId: toolId, isFavorited: false)
                }
                .eraseToAnyPublisher()
        }
        else {
            
            return favoritedResourcesRepository
                .storeFavoritedResourcesPublisher(ids: [toolId])
                .map { _ in
                    ToolIsFavoritedDomainModel(dataModelId: toolId, isFavorited: true)
                }
                .eraseToAnyPublisher()
        }
    }
}
