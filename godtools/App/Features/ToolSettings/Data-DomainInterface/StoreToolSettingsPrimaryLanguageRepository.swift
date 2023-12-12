//
//  StoreToolSettingsPrimaryLanguageRepository.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class StoreToolSettingsPrimaryLanguageRepository: StoreToolSettingsPrimaryLanguageRepositoryInterface {
    
    private let toolSettingsRepository: ToolSettingsRepository
    
    init(toolSettingsRepository: ToolSettingsRepository) {
        
        self.toolSettingsRepository = toolSettingsRepository
    }
    
    func storeLanguagePublisher(language: LanguageDomainModel) -> AnyPublisher<Void, Never> {
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
