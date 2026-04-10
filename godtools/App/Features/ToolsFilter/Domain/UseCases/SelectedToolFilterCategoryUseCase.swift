//
//  SelectedToolFilterCategoryUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

final class SelectedToolFilterCategoryUseCase {
    
    private let userToolFiltersRepository: UserToolFiltersRepository
    
    init(userToolFiltersRepository: UserToolFiltersRepository) {
        
        self.userToolFiltersRepository = userToolFiltersRepository
    }
    
    func execute(id: String?) -> AnyPublisher<Void, Never> {
        
        userToolFiltersRepository.storeUserToolCategoryFilter(with: id)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
