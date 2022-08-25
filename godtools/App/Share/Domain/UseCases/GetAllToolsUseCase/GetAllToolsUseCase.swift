//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetAllToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllToolsPublisher(sorted: Bool) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[ToolDomainModel], Never> in
                
                let tools = self.getAllTools(sorted: sorted)
                
                return Just(tools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllTools(sorted: Bool) -> [ToolDomainModel] {
        
        let metaTools = resourcesRepository.getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = resourcesRepository.getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = resourcesRepository.getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
   
        var allTools = combinedResourcesAndDefaultVariants.filter { $0.isToolType && $0.isHidden == false }
        
        if sorted {
            allTools = allTools.sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
        }
        
        return allTools.map { ToolDomainModel(resource: $0) }
    }
}
