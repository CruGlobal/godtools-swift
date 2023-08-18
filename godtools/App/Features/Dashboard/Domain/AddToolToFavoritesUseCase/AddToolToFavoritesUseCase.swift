//
//  AddToolToFavoritesUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/2/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class AddToolToFavoritesUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
     
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func addToolToFavoritesPublisher(id: String) -> AnyPublisher<Void, Never> {
             
        return favoritedResourcesRepository.storeFavoritedResourcesPublisher(ids: [id])
            .flatMap({ (favoritedResources: [FavoritedResourceDataModel]) -> AnyPublisher<Void, Never> in
                
                return Just(Void())
                    .eraseToAnyPublisher()
            })
            .catch({ (error: Error) -> AnyPublisher<Void, Never> in
                
                return Just(Void())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
