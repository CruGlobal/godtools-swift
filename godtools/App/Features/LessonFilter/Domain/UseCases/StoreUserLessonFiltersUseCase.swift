//
//  StoreUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserLessonFiltersUseCase {
    
    private let storeUserLessonFiltersRepository: StoreUserLessonFiltersRepositoryInterface
    
    init(storeUserLessonFiltersRepository: StoreUserLessonFiltersRepositoryInterface) {
        self.storeUserLessonFiltersRepository = storeUserLessonFiltersRepository
    }
    
    func storeLanguageFilterPublisher(with id: String) -> AnyPublisher<Void, Never> {
        
        return storeUserLessonFiltersRepository.storeUserLanguageFilterPublisher(with: id)
            .eraseToAnyPublisher()
    }
}