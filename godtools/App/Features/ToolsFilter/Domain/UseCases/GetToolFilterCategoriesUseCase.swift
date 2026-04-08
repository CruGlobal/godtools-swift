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
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filteredByLanguageId: BCP47LanguageIdentifier?) -> AnyPublisher<[ToolFilterCategoryDomainModel], Error> {
        
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { _ in
                
                let categoryIds = self.resourcesRepository
                    .getAllToolCategoryIds(filteredByLanguageId: filteredByLanguageId)
                
                let categories = self.getToolFilterCategory.createCategoryDomainModels(
                    from: categoryIds,
                    translatedInAppLanguage: appLanguage,
                    filteredByLanguageId: filteredByLanguageId
                )
                
                return Just(categories)
            }
            .eraseToAnyPublisher()
    }
}
