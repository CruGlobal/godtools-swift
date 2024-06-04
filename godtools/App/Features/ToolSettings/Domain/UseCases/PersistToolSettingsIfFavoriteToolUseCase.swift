//
//  PersistToolSettingsIfFavoriteToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistToolSettingsIfFavoriteToolUseCase {
    
    private let persistToolSettingsIfFavoriteToolRepository: PersistToolSettingsIfFavoriteToolRepositoryInterface
    
    init(persistToolSettingsIfFavoriteToolRepositoryInterface: PersistToolSettingsIfFavoriteToolRepositoryInterface) {
        self.persistToolSettingsIfFavoriteToolRepository = persistToolSettingsIfFavoriteToolRepositoryInterface
    }
    
    func persistToolSettingsIfFavoriteToolPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        return persistToolSettingsIfFavoriteToolRepository.persistToolSettingsIfFavoriteToolPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
    }
}
