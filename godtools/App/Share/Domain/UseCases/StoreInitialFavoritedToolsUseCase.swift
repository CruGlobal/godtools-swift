//
//  StoreInitialFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreInitialFavoritedToolsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func execute() -> AnyPublisher<Void, Never> {
        
        guard favoritedResourcesRepository.getNumberOfFavoritedResources() == 0 else {
            return Just(Void())
                .eraseToAnyPublisher()
        }
        
        let favoritedResourceIdsToStore: [String] = ["2", "1", "4", "8"].reversed()
        
        return favoritedResourcesRepository
            .storeFavoritedResourcesPublisher(ids: favoritedResourceIdsToStore)
    }
}
