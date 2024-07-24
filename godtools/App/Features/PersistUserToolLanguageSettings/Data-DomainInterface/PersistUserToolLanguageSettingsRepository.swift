//
//  PersistUserToolLanguageSettingsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolLanguageSettingsRepository: PersistUserToolLanguageSettingsRepositoryInterface {
    
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(userToolSettingsRepository: UserToolSettingsRepository) {
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func persistUserToolLanguageSettingsPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        userToolSettingsRepository.storeUserToolSettings(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId
        )
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
