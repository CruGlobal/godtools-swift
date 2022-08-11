//
//  GetAllFavoritedToolIDsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolIDsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getAllFavoritedToolIDsPublisher() -> AnyPublisher<[FavoritedResourceModel], Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
            .flatMap({ void -> AnyPublisher<[FavoritedResourceModel], Never> in
                
                return Just(self.getAllFavoritedToolIDs())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAllFavoritedToolIDs() -> [FavoritedResourceModel] {
        
        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
    }
}
