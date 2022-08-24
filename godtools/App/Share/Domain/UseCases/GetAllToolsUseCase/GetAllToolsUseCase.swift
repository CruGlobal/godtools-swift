//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetAllToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    
    init(resourcesRepository: ResourcesRepository) {
        self.resourcesRepository = resourcesRepository
    }
    
    func getAllToolsSorted(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ToolDomainModel] {
        
        return getAllTools().sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
    }
    
    func getAllTools(andFilteredBy additionalFilter: ResourceFilter? = nil) -> [ToolDomainModel] {
        
        let metaTools = resourcesRepository.getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = resourcesRepository.getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = resourcesRepository.getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
        
        return combinedResourcesAndDefaultVariants
            .filter { resource in
                
                if let additionalFilter = additionalFilter, additionalFilter(resource) == false {
                    return false
                }
                
                return resource.isToolType && resource.isHidden == false
                
            }
            .map { ToolDomainModel(resource: $0) }
    }
}
