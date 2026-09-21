//
//  SetUserPersonalizedLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class SetUserPersonalizedLessonFilterLanguageUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
    }
    
    func execute(language: PersonalizedLessonFilterLanguageDomainModel) async throws {
        
        try await userToolFilterSettingsRepository.storeSettingValue(
            settingType: .personalizedLessonsLanguageFilter,
            value: language.languageId
        )
    }
}
