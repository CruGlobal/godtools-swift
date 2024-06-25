//
//  PersistUserToolSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolSettingsUseCase {
    
    private let persistUserToolSettingsRepository: PersistUserToolSettingsRepositoryInterface
    
    init(persistUserToolSettingsRepositoryInterface: PersistUserToolSettingsRepositoryInterface) {
        self.persistUserToolSettingsRepository = persistUserToolSettingsRepositoryInterface
    }
    
    func persistUserToolSettingsPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?, selectedLanguageId: String) -> AnyPublisher<Bool, Never> {
        
        return persistUserToolSettingsRepository.persistUserToolSettingsPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId, selectedLanguageId: selectedLanguageId)
    }
}
