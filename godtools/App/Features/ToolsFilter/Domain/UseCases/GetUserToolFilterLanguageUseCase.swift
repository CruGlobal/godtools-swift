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
                
                let languageId: String? = self.userToolFiltersRepository.getUserToolLanguageFilter()?.languageId
                
                if let languageId = languageId,
                   let languageFilter = self.getToolFilterLanguage.getLanguageFilter(languageId: languageId, translatedInAppLanguage: appLanguage) {
                    
                    return languageFilter
                }
                
                return self.getToolFilterLanguage.getAnyLanguageFilter(translatedInAppLanguage: appLanguage)
            }
            .eraseToAnyPublisher()
    }
}
