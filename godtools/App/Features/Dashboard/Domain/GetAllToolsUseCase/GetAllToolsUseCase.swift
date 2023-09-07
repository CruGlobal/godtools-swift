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
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolUseCase: GetToolUseCase, resourcesRepository: ResourcesRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getToolsForCategoryPublisher(category: CurrentValueSubject<String?, Never>) -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest3(
            resourcesRepository.getResourcesChanged(),
            category,
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
        )
        .flatMap({ (resourcesChanged: Void, categoryId: String?, primaryLanguage: LanguageDomainModel?) -> AnyPublisher<[ToolDomainModel], Never> in
                
            let tools = self.getAllTools(sorted: true, categoryId: categoryId)
                
            return Just(tools)
                .eraseToAnyPublisher()
        })
        .eraseToAnyPublisher()
    }
    
    func getAllTools(sorted: Bool, categoryId: String? = nil, languageId: String? = nil) -> [ToolDomainModel] {
        
        return resourcesRepository.getAllTools(sorted: sorted, category: categoryId, languageId: languageId).map {
            getToolUseCase.getTool(resource: $0)
        }
    }
}
