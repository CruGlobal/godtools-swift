//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetAllToolsUseCase {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolUseCase: GetToolUseCase
    private let resourcesRepository: ResourcesRepository
    
    private var allToolsInMem: [ToolDomainModel]?
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolUseCase: GetToolUseCase, resourcesRepository: ResourcesRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolsForFilterSelectionPublisher(filterSelection: CurrentValueSubject<ToolFilterSelection, Never>, categoryFilterSelection: CurrentValueSubject<CategoryFilterDomainModel, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest4(
            resourcesRepository.getResourcesChangedPublisher(),
            filterSelection,
            categoryFilterSelection,
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
        .flatMap({ (resourcesChanged: Void, filterSelection: ToolFilterSelection, categorySelection, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[ToolDomainModel], Never> in
                
            let tools = self.getAllTools(sorted: true, categoryId: categorySelection.categoryId, languageId: filterSelection.selectedLanguage.id)
                
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
        
        return resourcesRepository.getAllTools(sorted: sorted, category: categoryId, languageId: languageId).map {
            getToolUseCase.getTool(resource: $0)
        }
    }
}
