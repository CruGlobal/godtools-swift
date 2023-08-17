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
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
            .flatMap({ (favoritedResourcesChanged: Void) -> AnyPublisher<Bool, Never> in
                
                return Just(self.getToolIsFavorited(id: id))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    // TODO: - change this to pass in the id instead of tool (GT-1777)
    func getToolIsFavorited(id: String) -> Bool {
        
        return favoritedResourcesRepository.getFavoritedResource(resourceId: id) != nil
    }
}
