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
    
    func execute() -> AnyPublisher<Void, Error> {
        
        do {
        
            let favoritedResourceCount: Int = try favoritedResourcesRepository
                .persistence
                .getObjectCount()
            
            guard favoritedResourceCount == 0 else {
                return Just(Void())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            let favoritedResourceIdsToStore: [String] = ["2", "1", "4", "8"].reversed()
            
            return favoritedResourcesRepository
                .storeFavoritedResourcesPublisher(ids: favoritedResourceIdsToStore)
            
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
