//
//  UserDidDeleteParallelLanguageUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 7/31/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class UserDidDeleteParallelLanguageUseCase {
    
    private let languageSettingsRepository: LanguageSettingsRepository
    
    init(languageSettingsRepository: LanguageSettingsRepository) {
        
        self.languageSettingsRepository = languageSettingsRepository
    }
    
    func deleteParallelLanguage() {
        
        languageSettingsRepository.deleteParallelLanguage()
    }
}
