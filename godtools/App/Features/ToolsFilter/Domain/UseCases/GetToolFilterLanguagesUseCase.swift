//
//  GetToolFilterLanguagesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 2/27/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetToolFilterLanguagesUseCase {
    
    private let resourcesRepository: ResourcesRepository
    private let getToolFilterLanguage: GetToolFilterLanguage
    
    init(resourcesRepository: ResourcesRepository, getToolFilterLanguage: GetToolFilterLanguage) {
        
        self.resourcesRepository = resourcesRepository
        self.getToolFilterLanguage = getToolFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel, filteredByCategoryId: String?) -> AnyPublisher<[ToolFilterLanguageDomainModel], Error> {
        
        return resourcesRepository
            .persistence
            .observeCollectionChangesPublisher()
            .flatMap { _ in
                
                let languageIds = self.resourcesRepository
                    .getAllToolLanguageIds(filteredByCategoryId: filteredByCategoryId)
                
                return self.getToolFilterLanguage.createLanguageFilterDomainModelListPublisher(
                    from: languageIds,
                    translatedInAppLanguage: appLanguage,
                    filteredByCategoryId: filteredByCategoryId
                )
            }
            .eraseToAnyPublisher()
    }
}
