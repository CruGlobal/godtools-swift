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
    
    func getToolsWithCategoryPublisher(category: CurrentValueSubject<String?, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(resourcesRepository.getResourcesChanged(), category)
            .flatMap { (_, category) -> AnyPublisher<[ToolDomainModel], Never> in
                
                let tools = self.getAllTools(sorted: true, with: category)
                
                return Just(tools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAllToolsPublisher(sorted: Bool) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[ToolDomainModel], Never> in
                
                let toolResources = self.getAllTools(sorted: sorted)
                
                return Just(toolResources)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getAllToolsResourceModelPublisher(sorted: Bool) -> AnyPublisher<[ResourceModel], Never> {
        
        return resourcesRepository.getResourcesChanged()
            .flatMap { _ -> AnyPublisher<[ResourceModel], Never> in
                
                let toolResources = self.getAllToolsResourceModels(sorted: sorted)
                
                return Just(toolResources)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllTools(sorted: Bool, with category: String? = nil) -> [ToolDomainModel] {
        
        return getAllToolsResourceModels(sorted: sorted, with: category)
            .map { getToolUseCase.getTool(resource: $0) }
    }
    
    func getAllToolsResourceModels(sorted: Bool, with category: String? = nil) -> [ResourceModel] {
        
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
