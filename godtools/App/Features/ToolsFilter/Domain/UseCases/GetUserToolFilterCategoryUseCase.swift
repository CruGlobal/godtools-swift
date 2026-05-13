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
                
                let categoryId: String? = self.userToolFiltersRepository.getUserToolCategoryFilter()?.categoryId
                
                if let categoryId = categoryId {
                    return self.getToolFilterCategory.getCategoryFilter(categoryId: categoryId, translatedInAppLanguage: appLanguage)
                }
                
                return self.getToolFilterCategory.getAnyCategoryFilter(translatedInAppLanguage: appLanguage)
                
            }
            .eraseToAnyPublisher()
    }
}
