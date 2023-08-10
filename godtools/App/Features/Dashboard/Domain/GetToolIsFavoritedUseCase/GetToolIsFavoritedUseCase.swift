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
    
    func getToolIsFavoritedPublisher(toolId: String) -> AnyPublisher<Bool, Never>  {
        
        return favoritedResourcesRepository.getFavoritedResourcesChanged()
            .flatMap({ void -> AnyPublisher<Bool, Never> in
                
                return Just(self.getToolIsFavorited(toolId: toolId))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    // TODO: - change this to pass in the id instead of tool (GT-1777)
    func getToolIsFavorited(toolId: String) -> Bool {
        
        return favoritedResourcesRepository.getFavoritedResource(resourceId: toolId) != nil
    }
}