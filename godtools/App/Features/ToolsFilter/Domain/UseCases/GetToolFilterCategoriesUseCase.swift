//
//  GetToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/21/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterCategoriesUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let getToolFilterCategory: GetToolFilterCategory

    init(resourcesRepository: ResourcesRepository, getToolFilterCategory: GetToolFilterCategory) {
        
        self.resourcesRepository = resourcesRepository
        self.getToolFilterCategory = getToolFilterCategory
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filteredByLanguage: ToolFilterLanguageDomainModel) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> {
        
        return resourcesRepository
            .observeCollectionChangesPublisher()
            .receive(on: DispatchQueue.global())
            .flatMap { (resourcesChanged: Void) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> in

                return AnyPublisher() {

                    let categoryIds = self.resourcesRepository
                        .getAllToolCategoryIds(filteredByLanguageId: filteredByLanguage.filterId)

                    return await self.getToolFilterCategory.createCategoryFilters(
                        from: categoryIds,
                        translatedInAppLanguage: appLanguage,
                        filteredByLanguageId: filteredByLanguage.filterId
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
