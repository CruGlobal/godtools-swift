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
        
        storeInitialFavoritedResourcesIfNeeded()
        
        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
    }
    
    private func storeInitialFavoritedResourcesIfNeeded() {
        
        guard favoritedResourcesRepository.numberOfFavoritedResources == 0 else {
            return
        }
                
        _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "2")
        _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "1")
        _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "4")
        _ = favoritedResourcesRepository.storeFavoritedResource(resourceId: "8")
    }
}
