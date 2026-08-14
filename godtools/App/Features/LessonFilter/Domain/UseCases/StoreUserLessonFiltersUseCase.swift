//
//  StoreUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class StoreUserLessonFiltersUseCase: Sendable {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository) {
        self.userLessonFiltersRepository = userLessonFiltersRepository
    }
    
    func execute(languageFilter: LessonFilterLanguageDomainModel) async throws {
        
        try await userLessonFiltersRepository.storeUserLessonLanguageFilter(
            languageId: languageFilter.languageId
        )
    }
}
