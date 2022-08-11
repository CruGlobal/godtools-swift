//
//  GetAllFavoritedToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/11/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetAllFavoritedToolsUseCase {
    
    private let getAllFavoritedToolIDsUseCase: GetAllFavoritedToolIDsUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getAllFavoritedToolIDsUseCase: GetAllFavoritedToolIDsUseCase, resourcesRepository: ResourcesRepository) {
        
        self.getAllFavoritedToolIDsUseCase = getAllFavoritedToolIDsUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllFavoritedToolsPublisher(filterOutHidden: Bool) -> AnyPublisher<[ResourceModel], Never> {
        
        return getAllFavoritedToolIDsUseCase.getAllFavoritedToolIDsPublisher()
            .flatMap { favoritedResourceModels -> AnyPublisher<[ResourceModel], Never> in
                
                let resourceIds = favoritedResourceModels.map { $0.resourceId }
                var favoritedResources = self.resourcesRepository.getResources(ids: resourceIds, maintainOrder: true)
                
                if filterOutHidden {
                    favoritedResources = favoritedResources.filter { $0.isHidden == false }
                }
                
                return Just(favoritedResources)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAllFavoritedTools(filterOutHidden: Bool) -> [ResourceModel] {
        
        return getAllFavoritedToolIDsUseCase.getAllFavoritedToolIDs()
            .compactMap({ favoritedResourceModel in
                
                guard let resource = self.resourcesRepository.getResource(id: favoritedResourceModel.resourceId) else { return nil }
                
                if filterOutHidden, resource.isHidden {
                    return nil
                }
                
                return resource
            })
    }
}
