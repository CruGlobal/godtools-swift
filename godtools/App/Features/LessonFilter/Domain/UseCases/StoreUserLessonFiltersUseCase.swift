//
//  StoreUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class StoreUserLessonFiltersUseCase {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository) {
        self.userLessonFiltersRepository = userLessonFiltersRepository
    }
    
    func execute(languageFilter: LessonFilterLanguageDomainModel) -> AnyPublisher<Void, Never> {
        
        Task {
            try await userLessonFiltersRepository.storeUserLessonLanguageFilter(
                languageId: languageFilter.languageId
            )
        }
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
