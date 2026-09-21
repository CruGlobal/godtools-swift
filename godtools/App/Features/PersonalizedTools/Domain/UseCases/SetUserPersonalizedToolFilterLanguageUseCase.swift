//
//  SetUserPersonalizedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class SetUserPersonalizedToolFilterLanguageUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
    }
    
    func execute(language: PersonalizedToolFilterLanguageDomainModel) async throws {
        
        try await userToolFilterSettingsRepository.storeSettingValue(
            settingType: .personalizedToolsLanguageFilter,
            value: language.languageId
        )
    }
}
