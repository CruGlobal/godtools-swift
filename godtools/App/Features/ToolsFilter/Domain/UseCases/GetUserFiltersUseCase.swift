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
        .flatMap { categoryFilterId, languageFilter in
            
            let userFilters = UserFiltersDomainModel(
                categoryFilterId: categoryFilterId,
                languageFilter: languageFilter
            )
            
            return Just(userFilters)
        }
        .eraseToAnyPublisher()
    }
}
