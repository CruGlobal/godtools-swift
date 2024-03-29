//
//  StoreUserToolFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserToolFiltersRepository: StoreUserToolFiltersRepositoryInterface {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
    }
    
    func storeUserCategoryFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        userToolFiltersRepository.storeUserCategoryFilter(with: id)
        
        return Just(())
            .eraseToAnyPublisher()
    }
    
    func storeUserLanguageFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        userToolFiltersRepository.storeUserLanguageFilter(with: id)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
