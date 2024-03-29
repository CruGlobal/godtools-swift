//
//  GetUserToolFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserToolFiltersRepository: GetUserToolFiltersRepositoryInterface {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    private let getToolFilterCategoriesRepository: GetToolFilterCategoriesRepository
    private let getToolFilterLanguagesRepository: GetToolFilterLanguagesRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository, getToolFilterCategoriesRepository: GetToolFilterCategoriesRepository, getToolFilterLanguagesRepository: GetToolFilterLanguagesRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
        self.getToolFilterCategoriesRepository = getToolFilterCategoriesRepository
        self.getToolFilterLanguagesRepository = getToolFilterLanguagesRepository
    }
    
    func getUserCategoryFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<CategoryFilterDomainModel, Never> {
        
        let categoryId = userToolFiltersRepository.getUserCategoryFilter()
        
        if let categoryFilter = getToolFilterCategoriesRepository.getCategoryFilter(from: categoryId, translatedInAppLanguage: translatedInAppLanguage) {
            
            return Just(categoryFilter)
                .eraseToAnyPublisher()
            
        } else {
            
            let defaultCategoryFilterValue = getToolFilterCategoriesRepository.getAnyCategoryFilterDomainModel(translatedInAppLanguage: translatedInAppLanguage)
            
            return Just(defaultCategoryFilterValue)
                .eraseToAnyPublisher()
        }
    }
    
    func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel, Never> {
        
        let languageId = userToolFiltersRepository.getUserLanguageFilter()
        
        if let languageFilter = getToolFilterLanguagesRepository.getLanguageFilter(from: languageId, translatedInAppLanguage: translatedInAppLanguage) {
            
            return Just(languageFilter)
                .eraseToAnyPublisher()
            
        } else {
            
            let defaultLanguageFilterValue = getToolFilterLanguagesRepository.getAnyLanguageFilterDomainModel(translatedInAppLanguage: translatedInAppLanguage)
            
            return Just(defaultLanguageFilterValue)
                .eraseToAnyPublisher()
        }
    }
}
