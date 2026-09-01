//
//  GetUserLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserLessonFilterLanguageUseCase: Sendable {
    
    typealias LanguageId = String
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    
    init(
        userLessonFiltersRepository: UserLessonFiltersRepository
    ) {
        
        self.userLessonFiltersRepository = userLessonFiltersRepository
    }
    
    @MainActor func execute() -> AnyPublisher<LanguageId?, Error> {
        
        return userLessonFiltersRepository.observeCollectionChangesPublisher()
            .map { (lessonFiltersChanged: Void) in

                return self.userLessonFiltersRepository.getUserLessonLanguageFilter()?.languageId
            }
            .eraseToAnyPublisher()
    }
}
