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
    
    func getAllToolsSorted() -> [ToolDomainModel] {
        
        return getAllTools().sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
    }
    
    func getAllTools() -> [ToolDomainModel] {
        
        let metaTools = resourcesRepository.getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = resourcesRepository.getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = resourcesRepository.getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
        
        return combinedResourcesAndDefaultVariants
            .map { ToolDomainModel(resource: $0) }
    }
}
