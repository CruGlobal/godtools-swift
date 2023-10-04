//
//  GetToolIsFavoritedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolIsFavoritedUseCase {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getToolIsFavoritedPublisher(id: String) -> AnyPublisher<Bool, Never>  {
        
        return favoritedResourcesRepository.getFavoritedResourcesChangedPublisher()
            .flatMap({ (favoritedResourcesChanged: Void) -> AnyPublisher<Bool, Never> in
                
                return self.favoritedResourcesRepository.getResourceIsFavoritedPublisher(id: id)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
