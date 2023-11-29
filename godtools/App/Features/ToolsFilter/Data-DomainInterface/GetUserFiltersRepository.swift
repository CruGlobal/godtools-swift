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
    
    init(userFiltersRepository: UserFiltersRepository) {
        
        self.userFiltersRepository = userFiltersRepository
    }
    
    func getUserCategoryFilterPublisher() -> AnyPublisher<String?, Never> {
        
        let categoryId = userFiltersRepository.getUserCategoryFilter()
        
        return Just(categoryId)
            .eraseToAnyPublisher()
    }
    
    func getUserLanguageFilterPublisher() -> AnyPublisher<String?, Never> {
        
        let languageId = userFiltersRepository.getUserLanguageFilter()
        
        return Just(languageId)
            .eraseToAnyPublisher()
    }
}
