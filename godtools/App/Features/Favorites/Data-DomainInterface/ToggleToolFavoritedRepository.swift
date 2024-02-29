//
//  ToggleToolFavoritedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ToggleToolFavoritedRepository: ToggleToolFavoritedRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func toggleFavoritedPublisher(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Never> {
        
        let resourceIsFavorited: Bool = favoritedResourcesRepository.getResourceIsFavorited(id: toolId)
        
        if resourceIsFavorited {
            
            return favoritedResourcesRepository.deleteFavoritedResourcePublisher(id: toolId)
                .catch { _ in
                    return Just(())
                        .eraseToAnyPublisher()
                }
                .map {
                    ToolIsFavoritedDomainModel(dataModelId: toolId, isFavorited: false)
                }
                .eraseToAnyPublisher()
        }
        else {
            
            return favoritedResourcesRepository.storeFavoritedResourcesPublisher(ids: [toolId])
                .catch { _ in
                    return Just([])
                        .eraseToAnyPublisher()
                }
                .map { _ in
                    ToolIsFavoritedDomainModel(dataModelId: toolId, isFavorited: true)
                }
                .eraseToAnyPublisher()
        }
    }
}
