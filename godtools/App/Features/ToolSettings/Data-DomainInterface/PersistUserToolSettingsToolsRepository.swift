//
//  PersistUserToolSettingsToolRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolSettingsToolsRepository: PersistUserToolSettingsToolRepositoryInterface {
    
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(userToolSettingsRepository: UserToolSettingsRepository) {
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func persistUserToolSettingsToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) -> AnyPublisher<Bool, Never> {
        
        userToolSettingsRepository.storeUserToolSettings(
            toolId: toolId,
            primaryLanguageId: primaryLanguageId,
            parallelLanguageId: parallelLanguageId,
            selectedLanguageId: selectedLanguageId
        )
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
