//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetSpotlightToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        self.resourcesRepository = resourcesRepository
    }
    
    func getSpotlightToolsPublisher() -> AnyPublisher<[ToolDomainModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[ToolDomainModel], Never> in
                
                let spotlightTools = self.resourcesRepository.getSpotlightTools()
                    .map { ToolDomainModel(resource: $0) }
                
                return Just(spotlightTools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
