//
//  SelectedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SelectedToolFilterLanguageUseCase: Sendable {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
    }
    
    func execute(languageId: String) async throws {
  
        guard languageId != ToolFilterLanguageDomainModel.anyId else {
            try await userToolFiltersRepository.deleteUserLanguageFilter()
            return
        }
        
        try await userToolFiltersRepository
            .storeUserLanguageFilter(languageId: languageId)
    }
}
