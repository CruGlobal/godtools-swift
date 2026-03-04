//
//  RemoveFavoritedToolUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class RemoveFavoritedToolUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute(toolId: String) -> AnyPublisher<[FavoritedResourceDataModel], Error> {
        
        return favoritedResourcesRepository
            .deleteFavoritedResourcePublisher(
                id: toolId
            )
            .map { (favoritedResources: [FavoritedResourceDataModel]) in
                
                return favoritedResources
            }
            .eraseToAnyPublisher()
    }
}
