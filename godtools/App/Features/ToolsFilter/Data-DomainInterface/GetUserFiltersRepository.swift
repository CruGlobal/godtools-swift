//
//  GetUserFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserFiltersRepository: GetUserFiltersRepositoryInterface {
    
    private let userFiltersRepository: UserFiltersRepository
    private let getToolFilterLanguagesRepository: GetToolFilterLanguagesRepository
    
    init(userFiltersRepository: UserFiltersRepository, getToolFilterLanguagesRepository: GetToolFilterLanguagesRepository) {
        
        self.userFiltersRepository = userFiltersRepository
        self.getToolFilterLanguagesRepository = getToolFilterLanguagesRepository
    }
    
    func getUserCategoryFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<String?, Never> {
        
        let categoryId = userFiltersRepository.getUserCategoryFilter()
        
        return Just(categoryId)
            .eraseToAnyPublisher()
    }
    
    func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel, Never> {
        
        let languageId = userFiltersRepository.getUserLanguageFilter()
        
        let languageFilter = getToolFilterLanguagesRepository.getLanguageFilter(from: languageId, translatedInAppLanguage: translatedInAppLanguage)
        
        let defaultLanguageFilterValue = getToolFilterLanguagesRepository.getAnyLanguageFilterDomainModel(translatedInAppLanguage: translatedInAppLanguage)
        
        return Just(languageFilter ?? defaultLanguageFilterValue)
            .eraseToAnyPublisher()
    }
}
