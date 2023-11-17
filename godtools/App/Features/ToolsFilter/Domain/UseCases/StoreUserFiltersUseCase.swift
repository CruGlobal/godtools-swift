//
//  StoreUserFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserFiltersUseCase {
    
    private let storeUserFiltersRepositoryInterface: StoreUserFiltersRepositoryInterface
    
    init(storeUserFiltersRepositoryInterface: StoreUserFiltersRepositoryInterface) {
        
        self.storeUserFiltersRepositoryInterface = storeUserFiltersRepositoryInterface
    }
    
    func storeCategoryFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        return storeUserFiltersRepositoryInterface
            .storeUserCategoryFilterPublisher(with: id)
            .eraseToAnyPublisher()
    }
    
    func storeLanguageFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        return storeUserFiltersRepositoryInterface
            .storeUserLanguageFilterPublisher(with: id)
            .eraseToAnyPublisher()
    }
}
