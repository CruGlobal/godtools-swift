//
//  GetToolIsFavoritedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolIsFavoritedRepository: GetToolIsFavoritedRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getIsFavoritedPublisher(toolId: String) -> AnyPublisher<ToolIsFavoritedDomainModel, Never> {
        
        return favoritedResourcesRepository.getFavoritedResourcesChangedPublisher()
            .flatMap({ (favoritedResourcesChanged: Void) -> AnyPublisher<Bool, Never> in
                
                return self.favoritedResourcesRepository.getResourceIsFavoritedPublisher(id: toolId)
                    .eraseToAnyPublisher()
            })
            .map { (isFavorited: Bool) in
                
                return ToolIsFavoritedDomainModel(
                    dataModelId: toolId,
                    isFavorited: isFavorited
                )
            }
            .eraseToAnyPublisher()
    }
}
