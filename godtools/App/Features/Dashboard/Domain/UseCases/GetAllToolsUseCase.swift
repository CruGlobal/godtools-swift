//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

@available(*, deprecated) 
class GetAllToolsUseCase {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let resourcesRepository: ResourcesRepository
    
    private var allToolsInMem: [ToolDomainModel]?
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, resourcesRepository: ResourcesRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolsForFilterSelectionPublisher(languagefilterSelection: CurrentValueSubject<LanguageFilterDomainModel, Never>, categoryFilterSelection: CurrentValueSubject<CategoryFilterDomainModel, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest4(
            resourcesRepository.getResourcesChangedPublisher(),
            languagefilterSelection,
            categoryFilterSelection,
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
        .flatMap({ (resourcesChanged: Void, languageSelection: LanguageFilterDomainModel, categorySelection, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[ToolDomainModel], Never> in
                
            let tools = self.getAllTools(sorted: true, categoryId: categorySelection.id, languageId: languageSelection.id)
                
            return Just(tools)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getAllTools(sorted: Bool, optimizeForBatchRequests: Bool = false, categoryId: String? = nil, languageId: String? = nil) -> [ToolDomainModel] {
        
        if optimizeForBatchRequests {
            
            return getFilteredInMemTools(sorted: sorted, categoryId: categoryId, languageId: languageId)
            
        } else {
            
            return getTools(sorted: sorted, categoryId: categoryId, languageId: languageId)
        }
    }
    
    private func getFilteredInMemTools(sorted: Bool, categoryId: String? = nil, languageId: String? = nil) -> [ToolDomainModel] {
        
        guard let allToolsInMem = allToolsInMem else {
            
            allToolsInMem = getTools(sorted: sorted)
            return getFilteredInMemTools(sorted: sorted, categoryId: categoryId, languageId: languageId)
        }

        return allToolsInMem.filter { tool in
            
            if let category = categoryId, tool.category != category {
                return false
            }
            
            if let languageId = languageId, tool.languageIds.contains(languageId) == false {
                return false
            }
            
            return true
        }
    }
    
    private func getTools(sorted: Bool, categoryId: String? = nil, languageId: String? = nil) -> [ToolDomainModel] {
        
        return Array()
        /*
        return resourcesRepository.getAllTools(sorted: sorted, category: categoryId, languageId: languageId).map {
            getToolUseCase.getTool(resource: $0)
        }*/
    }
}