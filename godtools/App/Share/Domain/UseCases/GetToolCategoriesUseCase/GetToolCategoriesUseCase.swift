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
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getAllToolsUseCase: GetAllToolsUseCase, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository) {
        self.getAllToolsUseCase = getAllToolsUseCase
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolCategoriesPublisher() -> AnyPublisher<[ToolCategoryDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
            .flatMap({ _, primaryLanguage -> AnyPublisher<[ToolCategoryDomainModel], Never> in
                
                let toolResources = self.getAllToolsUseCase.getAllToolsResourceModels(sorted: false)
                let sortedResources = self.sortToolsByPrimaryLanguageAvailable(toolResources, primaryLanguage: primaryLanguage)
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
        
        return uniqueCategories.map { ToolCategoryDomainModel(categoryName: $0) }
    }
    
    private func sortToolsByPrimaryLanguageAvailable(_ toolResources: [ResourceModel], primaryLanguage: LanguageDomainModel?) -> [ResourceModel] {
        guard let primaryLanguageId = primaryLanguage?.id else { return toolResources }
        
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
