//
//  RemoveToolFromFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class RemoveToolFromFavoritesUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func removeToolFromFavoritesPublisher(id: String) -> AnyPublisher<Void, Never> {
        
        return favoritedResourcesRepository.deleteFavoritedResourcePublisher(id: id)
            .catch({ (error: Error) -> AnyPublisher<Void, Never> in
              
                return Just(Void())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
