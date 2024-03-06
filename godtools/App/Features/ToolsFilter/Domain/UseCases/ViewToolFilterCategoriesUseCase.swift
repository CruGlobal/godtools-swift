//
//  ViewToolFilterCategoriesUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 3/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class ViewToolFilterCategoriesUseCase {
    
    private let getToolFilterCategoriesRepository: GetToolFilterCategoriesRepositoryInterface
    
    init(getToolFilterCategoriesRepository: GetToolFilterCategoriesRepositoryInterface) {
        
        self.getToolFilterCategoriesRepository = getToolFilterCategoriesRepository
    }
    
    func viewPublisher(filteredByLanguageId: String?, translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<ViewToolFilterCategoriesDomainModel, Never> {
        
        return getToolFilterCategoriesRepository.getToolFilterCategoriesPublisher(translatedInAppLanguage: translatedInAppLanguage, filteredByLanguageId: filteredByLanguageId)
            .map { categoryFilters in
            
                return ViewToolFilterCategoriesDomainModel(
                    categoryFilters: categoryFilters
                )
            }
            .eraseToAnyPublisher()
    }
}
