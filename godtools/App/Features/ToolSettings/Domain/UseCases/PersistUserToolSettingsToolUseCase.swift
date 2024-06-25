//
//  PersistUserToolSettingsToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolSettingsToolUseCase {
    
    private let persistUserToolSettingsToolRepository: PersistUserToolSettingsToolRepositoryInterface
    
    init(persistUserToolSettingsToolRepositoryInterface: PersistUserToolSettingsToolRepositoryInterface) {
        self.persistUserToolSettingsToolRepository = persistUserToolSettingsToolRepositoryInterface
    }
    
    func persistUserToolSettingsToolPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) -> AnyPublisher<Bool, Never> {
        
        return persistUserToolSettingsToolRepository.persistUserToolSettingsToolPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId, selectedLanguageId: selectedLanguageId)
    }
}
