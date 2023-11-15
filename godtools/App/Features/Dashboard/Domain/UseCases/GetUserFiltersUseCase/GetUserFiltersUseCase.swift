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
    
    func getUserCategoryFilterIdPublisher() -> AnyPublisher<String?, Never> {
        
        return getUserFiltersRepositoryInterface.getUserCategoryFilterPublisher()
    }
    
    func getUserLanguageFilterIdPublisher() -> AnyPublisher<String?, Never> {
        
        return getUserFiltersRepositoryInterface.getUserLanguageFilterPublisher()
    }
}
