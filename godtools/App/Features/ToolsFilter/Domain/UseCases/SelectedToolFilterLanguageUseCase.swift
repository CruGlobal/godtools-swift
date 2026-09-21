//
//  SelectedToolFilterLanguageUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

final class SelectedToolFilterLanguageUseCase: Sendable {
    
    private let userToolFilterSettingsRepository: UserToolFilterSettingsRepository
    
    init(userToolFilterSettingsRepository: UserToolFilterSettingsRepository) {
        
        self.userToolFilterSettingsRepository = userToolFilterSettingsRepository
    }
    
    func execute(language: ToolFilterLanguageDomainModel) async throws {
        
        let languageId: String? = !language.isAny ? language.languageId : nil
        
        try await userToolFilterSettingsRepository.storeSettingValue(
            settingType: .toolsLanguageFilter,
            value: languageId
        )
    }
}
