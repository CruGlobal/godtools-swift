//
//  PersistToolLanguageSettingsForFavoritedToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class PersistToolLanguageSettingsForFavoritedToolUseCase {
    
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(userToolSettingsRepository: UserToolSettingsRepository) {
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func execute(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        userToolSettingsRepository.storeUserToolSettings(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
