//
//  GetSpotlightToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Combine

class GetSpotlightToolsUseCase {
    
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getToolUseCase: GetToolUseCase
    private let resourcesRepository: ResourcesRepository
    
    init(getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getToolUseCase: GetToolUseCase, resourcesRepository: ResourcesRepository) {
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getToolUseCase = getToolUseCase
        self.resourcesRepository = resourcesRepository
    }
    
    func getSpotlightToolsPublisher() -> AnyPublisher<[ToolDomainModel], Never> {
        
        return Publishers.CombineLatest(
            resourcesRepository.getResourcesChanged(),
            getSettingsPrimaryLanguageUseCase.getPrimaryLanguagePublisher()
            )
            .flatMap { _ -> AnyPublisher<[ToolDomainModel], Never> in
                
                let spotlightTools = self.resourcesRepository.getSpotlightTools()
                    .map { self.getToolUseCase.getTool(resource: $0) }
                
                return Just(spotlightTools)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
