//
//  GetUserFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/13/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserFiltersUseCase {
    
    private let getUserFiltersRepositoryInterface: GetUserFiltersRepositoryInterface
    
    init(getUserFiltersRepositoryInterface: GetUserFiltersRepositoryInterface) {
        
        self.getUserFiltersRepositoryInterface = getUserFiltersRepositoryInterface
    }
    
    func getUserFiltersPublisher(translatedInAppLanguage: AppLanguageDomainModel) -> AnyPublisher<UserFiltersDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getUserFiltersRepositoryInterface.getUserCategoryFilterPublisher(translatedInAppLanguage: translatedInAppLanguage),
            getUserFiltersRepositoryInterface.getUserLanguageFilterPublisher(translatedInAppLanguage: translatedInAppLanguage)
        )
        .flatMap { categoryFilter, languageFilter in
            
            let userFilters = UserFiltersDomainModel(
                categoryFilter: categoryFilter,
                languageFilter: languageFilter
            )
            
            return Just(userFilters)
        }
        .eraseToAnyPublisher()
    }
}
