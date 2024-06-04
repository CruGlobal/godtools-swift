//
//  PersistToolSettingsIfFavoriteToolRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistToolSettingsIfFavoriteToolsRepository: PersistToolSettingsIfFavoriteToolRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let toolSettingsRepository: ToolSettingsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, toolSettingsRepository: ToolSettingsRepository) {
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.toolSettingsRepository = toolSettingsRepository
    }
    
    func persistToolSettingsIfFavoriteToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        guard favoritedResourcesRepository.getResourceIsFavorited(id: toolId) else {
            
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        toolSettingsRepository.storeToolSettings(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
