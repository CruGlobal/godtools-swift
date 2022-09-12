//
//  GetAllFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 8/3/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsUseCase {
    
    private let getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getAllFavoritedResourceModelsUseCase: GetAllFavoritedResourceModelsUseCase, resourcesRepository: ResourcesRepository) {
        
        self.getAllFavoritedResourceModelsUseCase = getAllFavoritedResourceModelsUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllFavoritedToolsPublisher() -> AnyPublisher<[ToolDomainModel], Never> {
        
        return getAllFavoritedResourceModelsUseCase.getAllFavoritedResourceModelsPublisher()
            .flatMap { favoritedResourceModels -> AnyPublisher<[ToolDomainModel], Never> in
                
                let favoritedTools = self.getFavoritedTools(from: favoritedResourceModels)
                
                return Just(favoritedTools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getFavoritedTools(from favoritedResourceModels: [FavoritedResourceModel]) -> [ToolDomainModel] {
        
        let favoritedResourceIds: [String] = favoritedResourceModels.map { $0.resourceId }
        let resources: [ResourceModel] = resourcesRepository.getResources(ids: favoritedResourceIds)
                
        return resources.map { ToolDomainModel(resource: $0) }
    }
}
