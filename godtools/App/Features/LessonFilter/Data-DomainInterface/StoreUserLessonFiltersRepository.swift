//
//  StoreUserLessonFiltersRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreUserLessonFiltersRepository: StoreUserLessonFiltersRepositoryInterface {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository) {
        self.userLessonFiltersRepository = userLessonFiltersRepository
    }
    
    func storeUserLanguageFilterPublisher(_ languageFilter: LessonLanguageFilterDomainModel) -> AnyPublisher<Void, Never> {
        
        userLessonFiltersRepository.storeUserLessonLanguageFilter(with: languageFilter.languageId)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
