//
//  GetAllFavoritedResourceModelsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedResourceModelsUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getAllFavoritedResourceModelsPublisher() -> AnyPublisher<[FavoritedResourceModel], Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
            .flatMap({ void -> AnyPublisher<[FavoritedResourceModel], Never> in
                
                return Just(self.getAllFavoritedResourceModels())
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    func getAllFavoritedResourceModels() -> [FavoritedResourceModel] {
                
        return favoritedResourcesRepository.getFavoritedResourcesSortedByCreatedAt(ascendingOrder: false)
    }
}
