//
//  StoreInitialFavoritedTools.swift
//  godtools
//
//  Created by Levi Eggert on 5/24/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialFavoritedTools: StoreInitialFavoritedToolsInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func storeInitialFavoritedToolsPublisher() -> AnyPublisher<Void, Never> {
        
        guard favoritedResourcesRepository.getNumberOfFavoritedResources() == 0 else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        let favoritedResourceIdsToStore: [String] = ["2", "1", "4", "8"]
        
        return favoritedResourcesRepository
            .storeFavoritedResourcesPublisher(ids: favoritedResourceIdsToStore)
    }
}
