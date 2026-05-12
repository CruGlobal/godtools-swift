//
//  SelectedToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SelectedToolFilterCategoryUseCase {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
    }
    
    func execute(category: ToolFilterCategoryDomainModel) async throws {
        
        guard category.categoryType != .any else {
            try userToolFiltersRepository.deleteUserCategoryFilter()
            return
        }
        
        try await userToolFiltersRepository
            .storeUserCategoryFilter(categoryId: category.id)
    }
}
