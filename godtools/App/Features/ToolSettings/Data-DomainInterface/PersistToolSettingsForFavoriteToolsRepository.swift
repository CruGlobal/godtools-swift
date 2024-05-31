//
//  PersistToolSettingsForFavoriteToolsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistToolSettingsForFavoriteToolsRepository: PersistToolSettingsForFavoriteToolsRepositoryInterface {
    
    private let toolSettingsRepository: ToolSettingsRepository
    
    init(toolSettingsRepository: ToolSettingsRepository) {
        self.toolSettingsRepository = toolSettingsRepository
    }
    
    func persistToolSettingsForFavoriteToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Void, Never> {
        
        toolSettingsRepository.storeToolSettings(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
