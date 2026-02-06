//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAllToolsUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let getToolsListItems: GetToolsListItems
    
    init(resourcesRepository: ResourcesRepository, getToolsListItems: GetToolsListItems) {
        
        self.resourcesRepository = resourcesRepository
        self.getToolsListItems = getToolsListItems
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, languageIdForAvailabilityText: String?, filterToolsByCategory: ToolFilterCategoryDomainModel?, filterToolsByLanguage: ToolFilterLanguageDomainModel?) -> AnyPublisher<[ToolListItemDomainModel], Error> {
        
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .prepend(Void())
            .flatMap({ (resourcesChanged: Void) -> AnyPublisher<[ToolListItemDomainModel], Error> in
            
                let tools: [ResourceDataModel] = self.resourcesRepository.getAllToolsList(
                    filterByCategory: filterToolsByCategory?.id,
                    filterByLanguageId: filterToolsByLanguage?.id,
                    sortByDefaultOrder: true
                )

                return self.getToolsListItems
                    .mapToolsToListItemsPublisher(
                        tools: tools,
                        appLanguage: appLanguage,
                        languageIdForAvailabilityText: languageIdForAvailabilityText
                    )
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
