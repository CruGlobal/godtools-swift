//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetAllToolsUseCase {
    
    private let getToolUseCase: GetToolUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getToolUseCase: GetToolUseCase, resourcesRepository: ResourcesRepository) {
        self.getToolUseCase = getToolUseCase
        self.resourcesRepository = resourcesRepository
    }
}

// MARK: - Publishers

extension GetAllToolsUseCase {
    
    func getToolsForCategoryPublisher(category: CurrentValueSubject<String?, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(resourcesRepository.getResourcesChanged(), category)
            .flatMap { (_, categoryId) -> AnyPublisher<[ToolDomainModel], Never> in
                
                let category: String?
                if categoryId == GetToolCategoriesUseCase.allToolsCategoryId {
                    category = nil
                } else {
                    category = categoryId
                }
                
                let tools = self.getAllTools(sorted: true, with: category)
                
                return Just(tools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Tool Getters

extension GetAllToolsUseCase {
    
    private func getAllTools(sorted: Bool, with category: String? = nil) -> [ToolDomainModel] {
        
        return getAllToolResources(sorted: sorted, with: category)
            .map { getToolUseCase.getTool(resource: $0) }
    }
    
    func getAllToolResources(sorted: Bool, with category: String? = nil) -> [ResourceModel] {
        
        let metaTools = resourcesRepository.getResources(with: .metaTool)
        let defaultVariantIds = metaTools.compactMap { $0.defaultVariantId }
        let defaultVariants = resourcesRepository.getResources(ids: defaultVariantIds)
        
        let resourcesExcludingVariants = resourcesRepository.getResources(with: ["", nil])
        
        let combinedResourcesAndDefaultVariants = resourcesExcludingVariants + defaultVariants
   
        var allTools = combinedResourcesAndDefaultVariants.filter { resource in
                        
            if let category = category, resource.attrCategory != category {
                return false
            }
            
            return resource.isToolType && resource.isHidden == false
            
        }
        
        if sorted {
            allTools = allTools.sorted(by: { $0.attrDefaultOrder < $1.attrDefaultOrder })
        }
        
        return allTools
    }
}
