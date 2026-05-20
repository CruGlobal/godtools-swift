//
//  SetAppLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SetAppLanguageUseCase {
    
    private let userAppLanguageRepository: UserAppLanguageRepository
    private let userLessonFiltersRepository: UserLessonFiltersRepository
    private let languagesRepository: LanguagesRepository
    
    init(userAppLanguageRepository: UserAppLanguageRepository, userLessonFiltersRepository: UserLessonFiltersRepository, languagesRepository: LanguagesRepository) {
        
        self.userAppLanguageRepository = userAppLanguageRepository
        self.userLessonFiltersRepository = userLessonFiltersRepository
        self.languagesRepository = languagesRepository
    }
    
    func execute(appLanguage: AppLanguageDomainModel) async throws -> AppLanguageDomainModel {
        
        if let languageModelId = languagesRepository.getLanguageByCode(code: appLanguage)?.id {
            
            try await userLessonFiltersRepository.storeUserLessonLanguageFilter(
                languageId: languageModelId
            )
        }
        
        try await userAppLanguageRepository
            .storeLanguage(appLanguageId: appLanguage)
        
        return appLanguage
    }
}
