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
    
    func getToolsForCategoryPublisher(category: CurrentValueSubject<String?, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(resourcesRepository.getResourcesChanged(), category)
            .flatMap { (_, categoryId) -> AnyPublisher<[ToolDomainModel], Never> in
                
                let tools = self.getAllTools(sorted: true, with: categoryId)
                
                return Just(tools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllTools(sorted: Bool, with category: String? = nil) -> [ToolDomainModel] {
        
        return resourcesRepository.getAllTools(sorted: sorted, with: category)
            .map { getToolUseCase.getTool(resource: $0) }
    }
}
