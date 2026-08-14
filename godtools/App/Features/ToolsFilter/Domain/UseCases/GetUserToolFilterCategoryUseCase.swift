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
            .flatMap {
                return AnyPublisher() {
                    return await self.asyncExecute(appLanguage: appLanguage)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func asyncExecute(appLanguage: AppLanguageDomainModel) async -> ToolFilterCategoryDomainModel {
        
        let categoryId: String? = userToolFiltersRepository.getUserToolCategoryFilter()?.categoryId
        
        if let categoryId = categoryId {
            
            return await getToolFilterCategory.getCategoryFilter(
                categoryId: categoryId,
                translatedInAppLanguage: appLanguage
            )
        }
        
        return await getToolFilterCategory.getAnyCategoryFilter(translatedInAppLanguage: appLanguage)
    }
}
