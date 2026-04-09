//
//  GetUserToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterCategoryUseCase {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    private let getToolFilterCategory: GetToolFilterCategory
    
    init(userToolFiltersRepository: UserToolFiltersRepository, getToolFilterCategory: GetToolFilterCategory) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
        self.getToolFilterCategory = getToolFilterCategory
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterCategoryDomainModel, Never> {
        
        return userToolFiltersRepository
            .getUserToolCategoryFilterChangedPublisher()
            .map {
                
                let categoryId = self.userToolFiltersRepository.getUserToolCategoryFilter()?.categoryId
                
                if let categoryFilter = self.getToolFilterCategory.getCategoryFilter(from: categoryId, translatedInAppLanguage: appLanguage) {
                    
                    return categoryFilter
                    
                } else {
                    
                    let defaultCategoryFilterValue = self.getToolFilterCategory.getAnyCategoryFilter(translatedInAppLanguage: appLanguage)
                    
                    return defaultCategoryFilterValue
                }
                
            }
            .eraseToAnyPublisher()
    }
}
