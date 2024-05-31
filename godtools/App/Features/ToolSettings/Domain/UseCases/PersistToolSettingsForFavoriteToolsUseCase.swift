//
//  PersistToolSettingsForFavoriteToolsUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 5/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class PersistToolSettingsForFavoriteToolsUseCase {
    
    private let persistToolSettingsForFavoriteToolsRepository: PersistToolSettingsForFavoriteToolsRepositoryInterface
    
    init(persistToolSettingsForFavoriteToolsRepositoryInterface: PersistToolSettingsForFavoriteToolsRepositoryInterface) {
        self.persistToolSettingsForFavoriteToolsRepository = persistToolSettingsForFavoriteToolsRepositoryInterface
    }
    
    func persistToolSettingsPublisher(with toolId: String, primaryLanguageId: String, parallelLanguageId: String?) -> AnyPublisher<Void, Never> {
        
        return persistToolSettingsForFavoriteToolsRepository.persistToolSettingsForFavoriteToolPublisher(toolId: toolId, primaryLanguageId: primaryLanguageId, parallelLanguageId: parallelLanguageId)
    }
}
