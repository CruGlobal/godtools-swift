//
//  GetUserToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserToolFilterLanguageUseCase {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    private let getToolFilterLanguage: GetToolFilterLanguage
    
    init(userToolFiltersRepository: UserToolFiltersRepository, getToolFilterLanguage: GetToolFilterLanguage) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
        self.getToolFilterLanguage = getToolFilterLanguage
    }
    
    @MainActor func execute(appLanguage: AppLanguageDomainModel) -> AnyPublisher<ToolFilterLanguageDomainModel, Never> {
        
        return userToolFiltersRepository
            .getUserToolLanguageFilterChangedPublisher()
            .map {
                let languageId = self.userToolFiltersRepository.getUserToolLanguageFilter()?.languageId
                
                if let languageFilter = self.getToolFilterLanguage.getLanguageFilter(from: languageId, translatedInAppLanguage: appLanguage) {
                    
                    return languageFilter
                    
                } else {
                    
                    let defaultLanguageFilterValue = self.getToolFilterLanguage.getAnyLanguageFilter(translatedInAppLanguage: appLanguage)
                    
                    return defaultLanguageFilterValue
                }
            }
            .eraseToAnyPublisher()
    }
}
