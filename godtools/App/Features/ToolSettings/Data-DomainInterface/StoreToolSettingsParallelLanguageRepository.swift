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
    
    func storeLanguagePublisher(languageId: String) -> AnyPublisher<Void, Never> {
        
        let parallelMatchesPrimary: Bool
        
        if let toolSettings = toolSettingsRepository.getSharedToolSettings() {
            parallelMatchesPrimary = toolSettings.primaryLanguageId != nil && toolSettings.primaryLanguageId == languageId
        }
        else {
            parallelMatchesPrimary = false
        }
        
        guard !parallelMatchesPrimary else {
            return Just(())
                .eraseToAnyPublisher()
        }
        
        return toolSettingsRepository
            .storeParallelLanguagePublisher(languageId: languageId)
            .eraseToAnyPublisher()

    }
}
