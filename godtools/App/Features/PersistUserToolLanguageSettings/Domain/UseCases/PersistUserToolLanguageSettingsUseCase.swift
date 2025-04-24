//
//  PersistUserToolLanguageSettingsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolLanguageSettingsUseCase: PersistToolLanguageSettingsInterface {
    
    private let persistUserToolLanguageSettingsRepository: PersistUserToolLanguageSettingsRepositoryInterface
    
    init(persistUserToolLanguageSettingsRepositoryInterface: PersistUserToolLanguageSettingsRepositoryInterface) {
        self.persistUserToolLanguageSettingsRepository = persistUserToolLanguageSettingsRepositoryInterface
    }
    
    func persistToolLanguageSettingsPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        return persistUserToolLanguageSettingsRepository.persistUserToolLanguageSettingsPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
    }
}
