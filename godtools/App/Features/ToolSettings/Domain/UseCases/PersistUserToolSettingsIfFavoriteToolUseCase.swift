//
//  PersistUserToolSettingsIfFavoriteToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolSettingsIfFavoriteToolUseCase {
    
    private let persistUserToolSettingsIfFavoriteToolRepository: PersistUserToolSettingsIfFavoriteToolRepositoryInterface
    
    init(persistUserToolSettingsIfFavoriteToolRepositoryInterface: PersistUserToolSettingsIfFavoriteToolRepositoryInterface) {
        self.persistUserToolSettingsIfFavoriteToolRepository = persistUserToolSettingsIfFavoriteToolRepositoryInterface
    }
    
    func persistUserToolSettingsIfFavoriteToolPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        return persistUserToolSettingsIfFavoriteToolRepository.persistUserToolSettingsIfFavoriteToolPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
    }
}
