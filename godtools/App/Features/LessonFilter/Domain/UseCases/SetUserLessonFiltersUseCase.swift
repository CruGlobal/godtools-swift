//
//  SetUserLessonFiltersUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SetUserLessonFiltersUseCase: Sendable {
    
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    
    init(userLessonFiltersRepository: UserLessonFiltersRepository) {
        self.userLessonFiltersRepository = userLessonFiltersRepository
    }
    
    func execute(languageId: String) async throws {
        
        try await userLessonFiltersRepository.storeUserLessonLanguageFilter(
            languageId: languageId
        )
    }
}
