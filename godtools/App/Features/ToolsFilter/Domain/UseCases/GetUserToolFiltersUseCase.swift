//
//  GetUserToolFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserToolFiltersUseCase {
    
    private let getUserToolFiltersRepositoryInterface: GetUserToolFiltersRepositoryInterface
    
    init(getUserToolFiltersRepositoryInterface: GetUserToolFiltersRepositoryInterface) {
        
        self.getUserToolFiltersRepositoryInterface = getUserToolFiltersRepositoryInterface
    }
    
    func getUserToolFiltersPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<UserToolFiltersDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getUserToolFiltersRepositoryInterface.getUserCategoryFilterPublisher(translatedInAppLanguage: translatedInAppLanguage),
            getUserToolFiltersRepositoryInterface.getUserLanguageFilterPublisher(translatedInAppLanguage: translatedInAppLanguage)
        )
        .flatMap { categoryFilter, languageFilter in
            
            let userFilters = UserToolFiltersDomainModel(
                categoryFilter: categoryFilter,
                languageFilter: languageFilter
            )
            
            return Just(userFilters)
        }
        .eraseToAnyPublisher()
    }
}
