//
//  GetToolDetailsToolIsFavoritedRepository.swift
//  godtools
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetToolDetailsToolIsFavoritedRepository: GetToolDetailsToolIsFavoritedRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository) {
        
        self.favoritedResourcesRepository = favoritedResourcesRepository
    }
    
    func getToolIsFavorited(tool: ToolDomainModel) -> AnyPublisher<Bool, Never> {
        
        return favoritedResourcesRepository.getResourceIsFavoritedPublisher(id: tool.id)
            .eraseToAnyPublisher()
    }
}
