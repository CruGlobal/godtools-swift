//
//  GetToolCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetToolCategoriesUseCase {
    
    private let getAllToolsUseCase: GetAllToolsUseCase
    private let languageSettingsRepository: LanguageSettingsRepository
    private let resourcesRepository: ResourcesRepository
    
    init(getAllToolsUseCase: GetAllToolsUseCase, languageSettingsRepository: LanguageSettingsRepository, resourcesRepository: ResourcesRepository) {
        self.getAllToolsUseCase = getAllToolsUseCase
        self.languageSettingsRepository = languageSettingsRepository
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolCategoriesPublisher() -> AnyPublisher<[ToolCategoryDomainModel], Never> {
        
        return getAllToolsUseCase.getAllToolsResourceModelPublisher(sorted: false)
            .flatMap({ toolResources -> AnyPublisher<[ToolCategoryDomainModel], Never> in
                
                let sortedResources = self.sortToolsByPrimaryLanguageAvailable(toolResources)
                let categories = self.getUniqueCategories(from: sortedResources)
                
                return Just(categories)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func getUniqueCategories(from toolResources: [ResourceModel]) -> [ToolCategoryDomainModel] {
        
        var uniqueCategories = [String]()
        toolResources.forEach { resource in
            
            let category = resource.attrCategory
            
            if uniqueCategories.contains(category) == false {
                uniqueCategories.append(category)
            }
        }
        
        return uniqueCategories.map { ToolCategoryDomainModel(category: $0) }
    }
    
    private func sortToolsByPrimaryLanguageAvailable(_ toolResources: [ResourceModel]) -> [ResourceModel] {
        guard let primaryLanguageId = languageSettingsRepository.getPrimaryLanguageId() else { return toolResources }
        
        return toolResources.sorted(by: { resource1, resource2 in
                        
            func resourceHasTranslation(_ resource: ResourceModel) -> Bool {
                return resourcesRepository.getResourceLanguageLatestTranslation(resourceId: resource.id, languageId: primaryLanguageId) != nil
            }
            
            func isInDefaultOrder() -> Bool {
                return resource1.attrDefaultOrder < resource2.attrDefaultOrder
            }
            
            if resourceHasTranslation(resource1) {
                
                if resourceHasTranslation(resource2) {
                    return isInDefaultOrder()
                    
                } else {
                    return true
                }
                
            } else if resourceHasTranslation(resource2) {

                return false
                
            } else {
                return isInDefaultOrder()
            }
        })
    }
}
