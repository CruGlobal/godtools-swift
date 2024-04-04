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
        
        return userToolFiltersRepository.getUserToolCategoryFilterChangedPublisher()
            .map {
                
                let categoryId = self.userToolFiltersRepository.getUserToolCategoryFilter()?.categoryId
                
                if let categoryFilter = self.getToolFilterCategoriesRepository.getCategoryFilter(from: categoryId, translatedInAppLanguage: translatedInAppLanguage) {
                    
                    return categoryFilter
                    
                } else {
                    
                    let defaultCategoryFilterValue = self.getToolFilterCategoriesRepository.getAnyCategoryFilterDomainModel(translatedInAppLanguage: translatedInAppLanguage)
                    
                    return defaultCategoryFilterValue
                }
                
            }
            .eraseToAnyPublisher()
    }
    
    func getUserLanguageFilterPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<LanguageFilterDomainModel, Never> {
        
        return userToolFiltersRepository.getUserToolLanguageFilterChangedPublisher()
            .map {
                let languageId = self.userToolFiltersRepository.getUserToolLanguageFilter()?.languageId
                
                if let languageFilter = self.getToolFilterLanguagesRepository.getLanguageFilter(from: languageId, translatedInAppLanguage: translatedInAppLanguage) {
                    
                    return languageFilter
                    
                } else {
                    
                    let defaultLanguageFilterValue = self.getToolFilterLanguagesRepository.getAnyLanguageFilterDomainModel(translatedInAppLanguage: translatedInAppLanguage)
                    
                    return defaultLanguageFilterValue
                }
            }
            .eraseToAnyPublisher()
    }
}
