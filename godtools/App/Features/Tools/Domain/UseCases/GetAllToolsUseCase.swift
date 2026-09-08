//
//  GetAllToolsUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetAllToolsUseCase: Sendable {
    
    private let resourcesRepository: ResourcesRepository
    private let getToolsListItems: GetToolsListItems
    
    init(resourcesRepository: ResourcesRepository, getToolsListItems: GetToolsListItems) {
        
        self.resourcesRepository = resourcesRepository
        self.getToolsListItems = getToolsListItems
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel,
        languageIdForAvailabilityText: String?,
        filterToolsByCategory: ToolFilterCategoryDomainModel,
        filterByLanguageId: String?
    ) -> AnyPublisher<[ToolListItemDomainModel], Error> {
        
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .prepend(Void())
            .map { (resourcesChanged: Void) in

                return self.getAllToolsList(
                    appLanguage: appLanguage,
                    languageIdForAvailabilityText: languageIdForAvailabilityText,
                    filterToolsByCategory: filterToolsByCategory,
                    filterByLanguageId: filterByLanguageId
                )
            }
            .eraseToAnyPublisher()
    }
    
    private func getAllToolsList(
        appLanguage: AppLanguageDomainModel,
        languageIdForAvailabilityText: String?,
        filterToolsByCategory: ToolFilterCategoryDomainModel,
        filterByLanguageId: String?
    ) -> [ToolListItemDomainModel] {
        
        let tools: [ResourceDataModel] = resourcesRepository.getAllToolsList(
            filterByCategory: filterToolsByCategory.filterId,
            filterByLanguageId: filterByLanguageId,
            sortByDefaultOrder: true
        )

        let toolListItems = self.getToolsListItems
            .mapToolsToListItems(
                tools: tools,
                appLanguage: appLanguage,
                languageIdForAvailabilityText: languageIdForAvailabilityText
            )

        return toolListItems
    }
}
