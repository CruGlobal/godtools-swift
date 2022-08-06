//
//  GetAllFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getAllFavoritedToolsPublisher() -> AnyPublisher<[FavoritedResourceModel], Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
            .flatMap({ void -> AnyPublisher<[FavoritedResourceModel], Never> in
                
                return Just(self.getAllFavoritedTools())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAllFavoritedTools() -> [FavoritedResourceModel] {
        
        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
    }
}
