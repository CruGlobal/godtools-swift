//
//  StoreToolSettingsParallelLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreToolSettingsParallelLanguageRepository: StoreToolSettingsParallelLanguageRepositoryInterface {
    
    private let toolSettingsRepository: ToolSettingsRepository
    
    init(toolSettingsRepository: ToolSettingsRepository) {
        
        self.toolSettingsRepository = toolSettingsRepository
    }
    
    func storeLanguagePublisher(language: ToolSettingsToolLanguageDomainModel) -> AnyPublisher<Void, Never> {
        
        return toolSettingsRepository
            .storeParallelLanguagePublisher(languageId: language.dataModelId)
            .eraseToAnyPublisher()

    }
}
