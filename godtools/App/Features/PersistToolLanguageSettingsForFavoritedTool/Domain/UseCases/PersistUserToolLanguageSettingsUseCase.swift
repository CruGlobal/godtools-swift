//
//  PersistToolLanguageSettingsForFavoritedToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class PersistToolLanguageSettingsForFavoritedToolUseCase {
    
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(userToolSettingsRepository: UserToolSettingsRepository) {
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func execute(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) async throws -> Bool {
        
        try await userToolSettingsRepository.storeUserToolSettings(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        return true
    }
}
