//
//  SetUserLessonFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 7/8/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class SetUserLessonFilterLanguageUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
    }
    
    func execute(language: LessonFilterLanguageDomainModel) async throws {
        
        try await userToolFilterSettingsRepository.storeSettingValue(
            settingType: .lessonsLanguageFilter,
            value: language.languageId
        )
    }
}
