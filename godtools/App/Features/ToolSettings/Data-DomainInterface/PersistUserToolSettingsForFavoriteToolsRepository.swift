//
//  PersistUserToolSettingsIfFavoriteToolRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 5/30/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistUserToolSettingsIfFavoriteToolsRepository: PersistUserToolSettingsIfFavoriteToolRepositoryInterface {
    
    private let favoritedResourcesRepository: FavoritedResourcesRepository
    private let userToolSettingsRepository: UserToolSettingsRepository
    
    init(favoritedResourcesRepository: FavoritedResourcesRepository, userToolSettingsRepository: UserToolSettingsRepository) {
        self.favoritedResourcesRepository = favoritedResourcesRepository
        self.userToolSettingsRepository = userToolSettingsRepository
    }
    
    func persistUserToolSettingsIfFavoriteToolPublisher(toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Bool, Never> {
        
        guard favoritedResourcesRepository.getResourceIsFavorited(id: toolId) else {
            
            return Just(false)
                .eraseToAnyPublisher()
        }
        
        userToolSettingsRepository.storeUserToolSettings(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
        
        return Just(true)
            .eraseToAnyPublisher()
    }
}
