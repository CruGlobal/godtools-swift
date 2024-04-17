//
//  StoreUserToolFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserToolFiltersUseCase {
    
    private let storeUserToolFiltersRepositoryInterface: StoreUserToolFiltersRepositoryInterface
    
    init(storeUserToolFiltersRepositoryInterface: StoreUserToolFiltersRepositoryInterface) {
        
        self.storeUserToolFiltersRepositoryInterface = storeUserToolFiltersRepositoryInterface
    }
    
    func storeCategoryFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        return storeUserToolFiltersRepositoryInterface
            .storeUserCategoryFilterPublisher(with: id)
            .eraseToAnyPublisher()
    }
    
    func storeLanguageFilterPublisher(with id: String?) -> AnyPublisher<Void, Never> {
        
        return storeUserToolFiltersRepositoryInterface
            .storeUserLanguageFilterPublisher(with: id)
            .eraseToAnyPublisher()
    }
}
