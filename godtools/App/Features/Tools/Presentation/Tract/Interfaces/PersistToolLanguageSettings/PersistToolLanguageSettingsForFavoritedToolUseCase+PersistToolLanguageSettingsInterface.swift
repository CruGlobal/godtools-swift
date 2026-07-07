//
//  PersistToolLanguageSettingsForFavoritedToolUseCase+PersistToolLanguageSettingsInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

extension PersistToolLanguageSettingsForFavoritedToolUseCase: PersistToolLanguageSettingsInterface {
    
    func persistSettings(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) async throws -> Bool {
        
        return try await execute(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
    }
}
