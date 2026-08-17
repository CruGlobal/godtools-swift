//
//  GetUserToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterCategoryUseCase: Sendable {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    private let getToolFilterCategory: GetToolFilterCategory
    
    init(userToolFiltersRepository: UserToolFiltersRepository, getToolFilterCategory: GetToolFilterCategory) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
        self.getToolFilterCategory = getToolFilterCategory
    }
    
    @MainActor func execute(
        appLanguage: AppLanguageDomainModel
    ) -> AnyPublisher<ToolFilterCategoryDomainModel, Never> {
        
        return userToolFiltersRepository
            .getUserToolCategoryFilterChangedPublisher()
            .receive(on: DispatchQueue.global())
            .map {
                return self.getToolFilterCategory(appLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
    
    private func getToolFilterCategory(appLanguage: AppLanguageDomainModel) -> ToolFilterCategoryDomainModel {
        
        let categoryId: String? = userToolFiltersRepository.getUserToolCategoryFilter()?.categoryId
        
        if let categoryId = categoryId {
            
            return getToolFilterCategory.getCategoryFilter(
                categoryId: categoryId,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return getToolFilterCategory.getAnyCategoryFilter(translatedInAppLanguage: appLanguage)
    }
}
