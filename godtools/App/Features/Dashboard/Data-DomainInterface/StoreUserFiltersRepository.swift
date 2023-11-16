//
//  StoreUserFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/8/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserFiltersRepository: StoreUserFiltersRepositoryInterface {
    
    private let userFiltersRepository: UserFiltersRepository
    
    init(userFiltersRepository: UserFiltersRepository) {
        
        self.userFiltersRepository = userFiltersRepository
    }
    
    func storeUserCategoryFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        userFiltersRepository.storeUserFilters(filter: .category(id: id))
        
        return Just(())
            .eraseToAnyPublisher()
    }
    
    func storeUserLanguageFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        userFiltersRepository.storeUserFilters(filter: .language(id: id))
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
