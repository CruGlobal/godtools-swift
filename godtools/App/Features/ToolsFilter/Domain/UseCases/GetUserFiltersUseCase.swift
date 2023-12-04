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
    
    func getUserFiltersPublisher() -> AnyPublisher<UserFiltersDomainModel, Never> {
        
        return Publishers.CombineLatest(
            getUserFiltersRepositoryInterface.getUserCategoryFilterPublisher(),
            getUserFiltersRepositoryInterface.getUserLanguageFilterPublisher()
        )
        .flatMap { categoryFilterId, languageFilterId in
            
            let userFilters = UserFiltersDomainModel(
                categoryFilterId: categoryFilterId,
                languageFilterId: languageFilterId
            )
            
            return Just(userFilters)
        }
        .eraseToAnyPublisher()
    }
}
