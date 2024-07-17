//
//  RemoveFavoritedToolRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoveFavoritedToolRepository: RemoveFavoritedToolRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func removeToolPublisher(toolId: String) -> AnyPublisher<Void, Never> {
        
        return favoritedResourcesRepository.deleteFavoritedResourcePublisher(id: toolId)
            .catch { _ in
                return Just(Void())
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
